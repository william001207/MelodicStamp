//
//  PlayerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import Accelerate
import CAAudioHardware
import Combine
import Defaults
import os.log
import SFBAudioEngine
import SwiftUI

// MARK: - Definition

extension PlayerModel {
    static let interval: TimeInterval = 0.1
    static let bufferSize: AVAudioFrameCount = 2048
}

@MainActor @Observable final class PlayerModel: NSObject {
    // MARK: Player

    private var player: any Player
    // The initialization is delayed to `setupEngine`
    private var analyzer: RealtimeAnalyzer!

    // MARK: Output Devices

    // Do not use computed variables for the sake of correctly updating view data
    private(set) var outputDevices: [AudioDevice] = []
    private(set) var defaultOutputDevice: AudioDevice?
    private(set) var defaultSystemOutputDevice: AudioDevice?

    private(set) var isUsingSystemOutputDevice: Bool = false
    private var _selectedOutputDevice: AudioDevice?

    // Exposed value, `nil` for system output device
    var selectedOutputDevice: AudioDevice? {
        get { isUsingSystemOutputDevice ? nil : _selectedOutputDevice }
        set {
            if let newValue {
                isUsingSystemOutputDevice = false
                _selectedOutputDevice = newValue
            } else {
                isUsingSystemOutputDevice = true
            }

            updateOutputDevices(forceUpdating: true)
        }
    }

    // MARK: Publishers

    private var cancellables = Set<AnyCancellable>()
    private let timer = TimerPublisher(interval: PlayerModel.interval)

    private var visualizationDataSubject = PassthroughSubject<[[Float]], Never>()
    var visualizationDataPublisher: AnyPublisher<[[Float]], Never> { visualizationDataSubject.eraseToAnyPublisher() }

    // MARK: Playlist & Playback

    private(set) var playlist: Playlist = .referenced()
    var selectedTracks: Set<Track> = []

    var playbackMode: PlaybackMode {
        get { playlist.playbackMode }
        set { playlist.playbackMode = newValue }
    }

    var playbackLooping: Bool {
        get { playlist.playbackLooping }
        set { playlist.playbackLooping = newValue }
    }

    private(set) var playbackState: PlaybackState = .stopped
    private(set) var playbackTime: PlaybackTime?
    var unwrappedPlaybackTime: PlaybackTime { playbackTime ?? .init() }

    // MARK: Responsive Fields

    var progress: CGFloat {
        get { unwrappedPlaybackTime.progress }

        set {
            player.seekProgress(to: newValue)
            updatePlaybackState()
            updateNowPlayingInfo(with: playbackState)
        }
    }

    var time: TimeInterval {
        get { unwrappedPlaybackTime.elapsed }

        set {
            player.seekTime(to: newValue)
            updatePlaybackState()
            updateNowPlayingInfo(with: playbackState)
        }
    }

    private var _volume: CGFloat = .zero
    var volume: CGFloat {
        get { _volume }

        set {
            _volume = newValue
            player.seekVolume(to: newValue)
        }
    }

    private var _isPlaying: Bool = false
    var isPlaying: Bool {
        get { _isPlaying }

        set {
            _isPlaying = newValue
            if isPlayable {
                player.setPlaying(isPlaying)
            } else {
                guard isPlaying else { return }
                play()
            }
        }
    }

    private(set) var isRunning: Bool = false

    private var _isMuted: Bool = false
    var isMuted: Bool {
        get { _isMuted }

        set {
            _isMuted = newValue
            player.setMuted(newValue)
        }
    }

    // MARK: Playlist

    var currentTrack: Track? {
        get { playlist.currentTrack }
        set { playlist.currentTrack = newValue }
    }

    var nextTrack: Track? {
        playlist.nextTrack
    }

    var previousTrack: Track? {
        playlist.previousTrack
    }

    var hasCurrentTrack: Bool {
        currentTrack != nil
    }

    var hasNextTrack: Bool {
        nextTrack != nil
    }

    var hasPreviousTrack: Bool {
        previousTrack != nil
    }

    var isPlaylistEmpty: Bool {
        playlist.isEmpty
    }

    var isPlayable: Bool {
        isRunning && hasCurrentTrack
    }

    // MARK: Initializers

    init(_ player: some Player) {
        self.player = player
        super.init()

        self.player.delegate = self
        setupRemoteTransportControls()
        setupEngine()

        timer
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.updateRunning()
                self.updatePlaying()
                self.updatePlaybackState()
                self.updatePlaybackTime()
                self.updateVolume()
                self.updateMuted()

                self.updateOutputDevices()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Functions

extension PlayerModel {
    private func updateRunning() {
        let updated = player.isRunning

        guard isRunning != updated else { return }
        isRunning = updated
    }

    private func updatePlaying() {
        let updated = player.isPlaying

        guard _isPlaying != updated else { return }
        _isPlaying = updated
    }

    private func updatePlaybackState() {
        let updated = player.playbackState
        guard playbackState != updated else { return }
        playbackState = updated
    }

    private func updatePlaybackTime() {
        if let updated = player.playbackTime {
            guard playbackTime != updated else { return }
            playbackTime = updated
        } else {
            playbackTime = nil
        }
    }

    private func updateVolume() {
        let updated = player.playbackVolume

        guard _volume != updated else { return }
        _volume = updated
    }

    private func updateMuted() {
        let updated = player.isMuted

        guard _isMuted != updated else { return }
        _isMuted = updated
    }
}

extension PlayerModel {
    // MARK: Play

    func play(_ url: URL) {
        Task {
            let track = await playlist.getOrCreateTrack(at: url)
            currentTrack = track

            if let track {
                player.play(track)
            }
        }
    }

    // MARK: Playlist

    func addToPlaylist(_ urls: [URL]) {
        for url in urls {
            Task {
                guard let track = await playlist.getOrCreateTrack(at: url) else { return }
                guard !playlist.contains(track) else { return }

                playlist.tracks.append(track)
            }
        }
    }

    func removeFromPlaylist(_ urls: [URL]) {
        for url in urls {
            Task {
                guard let track = await playlist.getOrCreateTrack(at: url) else { return }

                // Stops if the playing track is removed
                if currentTrack == track {
                    player.stop()
                    currentTrack = nil
                }

                // Removes from selected
                selectedTracks.remove(track)
            }
        }
    }

    func clearPlaylist() {
        removeFromPlaylist(playlist.map(\.url))
    }

    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlist.tracks.move(fromOffsets: indices, toOffset: destination)
    }

    // MARK: Convenient Functions

    func play() {
        if isRunning {
            player.play()
        } else if let currentTrack {
            play(currentTrack.url)
        }
    }

    func pause() {
        player.pause()
    }

    func stop() {
        volume = .zero
        isPlaying = false
        isMuted = false

        player.stop()
    }

    func togglePlayPause() {
        player.togglePlaying()
    }

    func playNextTrack() {
        guard let nextTrack else {
            stop()
            return
        }

        play(nextTrack.url)
    }

    func playPreviousTrack() {
        guard let previousTrack else {
            stop()
            return
        }

        play(previousTrack.url)
    }

    // MARK: Engine

    private func setupEngine() {
        player.withEngine { [weak self] engine in
            guard let self else { return }

            analyzer = .init(fftSize: Int(Self.bufferSize))

            // Audio visualization
            let inputNode = engine.mainMixerNode
            let bus = 0
            let format = inputNode.outputFormat(forBus: bus)

            inputNode.removeTap(onBus: bus)

            inputNode.installTap(onBus: bus, bufferSize: AVAudioFrameCount(PlayerModel.bufferSize), format: format) { [weak self] buffer, _ in
                guard let strongSelf = self else { return }
                if !strongSelf.player.isPlaying { return }

                buffer.frameLength = AVAudioFrameCount(Self.bufferSize)

                let spectra = strongSelf.analyzer.analyze(with: buffer)

                Task { @MainActor in
                    strongSelf.visualizationDataSubject.send(spectra)
                }
            }
        }
    }
}

// MARK: - Auxiliary Functions

extension PlayerModel {
    /*
         func analyzeFiles(urls: [URL]) {
             do {
                 let rg = try ReplayGainAnalyzer.analyzeAlbum(urls)
                 os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { url, replayGain in
                     String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
                 }.joined(separator: ", "))
                 // TODO: Notice user we're done
             } catch {}
         }

         func exportWAVEFile(url: URL) {
             let destURL = url.deletingPathExtension().appendingPathExtension("wav")
             if FileManager.default.fileExists(atPath: destURL.path) {
                 // TODO: Handle this
                 return
             }

             do {
                 try AudioConverter.convert(url, to: destURL)
                 try? AudioFile.copyMetadata(from: url, to: destURL)
             } catch {
                 try? FileManager.default.trashItem(at: destURL, resultingItemURL: nil)

             }
         }
     */

    // MARK: Output Devices

    private func selectOutputDevice(_ device: AudioDevice) {
        do {
            try player.selectOutputDevice(device)
        } catch {}
    }

    func updateOutputDevices(forceUpdating: Bool = false) {
        do {
            outputDevices = try player.availableOutputDevices()
            defaultOutputDevice = try player.defaultOutputDevice()
            defaultSystemOutputDevice = try player.defaultSystemOutputDevice()

            if isUsingSystemOutputDevice {
                if let defaultSystemOutputDevice, forceUpdating || defaultSystemOutputDevice != _selectedOutputDevice {
                    selectOutputDevice(defaultSystemOutputDevice)
                    _selectedOutputDevice = defaultSystemOutputDevice

                    print("Setting output device to system: \(defaultSystemOutputDevice)")
                }
            } else {
                if let device = _selectedOutputDevice, try forceUpdating || device != player.selectedOutputDevice() {
                    selectOutputDevice(device)

                    print("Setting output device to \(device)")
                }
            }
        } catch {}
    }
}

// MARK: - Delegates

extension PlayerModel: PlayerDelegate {
    nonisolated func playerDidFinishPlaying(_: some Melodic_Stamp.Player) {
        Task { @MainActor in
            if self.playbackLooping {
                if let currentTrack = self.currentTrack {
                    // Plays again
                    self.play(currentTrack.url)
                }
            } else {
                // Jumps to next track
                self.playNextTrack()
            }
        }
    }
}

extension PlayerModel: AudioPlayer.Delegate {
    nonisolated func audioPlayer(_: AudioPlayer, nowPlayingChanged nowPlaying: (any PCMDecoding)?) {
        Task { @MainActor in
            // Updates track, otherwise keeps it
            if let nowPlaying,
               let audioDecoder = nowPlaying as? AudioDecoder,
               let url = audioDecoder.inputSource.url {
                currentTrack = await playlist.getTrack(at: url)
            }

            updatePlaybackState()
            updateNowPlayingMetadataInfo(from: currentTrack)
            updateNowPlayingState(with: playbackState)
            updateNowPlayingInfo(with: playbackState)
        }
    }

    nonisolated func audioPlayer(_: AudioPlayer, playbackStateChanged playbackState: AudioPlayer.PlaybackState) {
        Task { @MainActor in
            updatePlaybackState()
            updateNowPlayingMetadataInfo(from: currentTrack)
            updateNowPlayingState(with: .init(playbackState))
            updateNowPlayingInfo(with: .init(playbackState))
        }
    }

    nonisolated func audioPlayer(_: AudioPlayer, encounteredError error: Error) {
        Task { @MainActor in
            stop()
            print(error)
        }
    }
}
