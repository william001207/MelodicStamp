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

@MainActor @Observable final class PlayerModel: NSObject {
    static let interval: TimeInterval = 0.1
    static let bufferSize: AVAudioFrameCount = 2048

    // MARK: Player

    private var player: any Player
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

    private(set) var track: Track?
    private(set) var playlist: [Track] = []

    var playbackMode: PlaybackMode = Defaults[.defaultPlaybackMode]
    var playbackLooping: Bool = false

    private(set) var playbackState: PlaybackState = .stopped
    private(set) var playbackTime: PlaybackTime?
    var unwrappedPlaybackTime: PlaybackTime { playbackTime ?? .init() }

    // MARK: Responsive Fields

    var progress: CGFloat {
        get {
            unwrappedPlaybackTime.progress
        }

        set {
            player.seekProgress(to: newValue)
            updatePlaybackState()
            updateNowPlayingInfo(with: playbackState)
        }
    }

    var time: TimeInterval {
        get {
            unwrappedPlaybackTime.elapsed
        }

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

    var isPlaylistEmpty: Bool {
        playlist.isEmpty
    }

    var isPlayable: Bool {
        isRunning && hasCurrentTrack
    }

    // MARK: Tracks & Indices

    var nextTrack: Track? {
        guard let nextIndex else { return nil }
        return playlist[nextIndex]
    }

    var previousTrack: Track? {
        guard let previousIndex else { return nil }
        return playlist[previousIndex]
    }

    var hasCurrentTrack: Bool {
        track != nil
    }

    var hasNextTrack: Bool {
        nextTrack != nil
    }

    var hasPreviousTrack: Bool {
        previousTrack != nil
    }

    private var index: Int? {
        guard let track else { return nil }
        return playlist.firstIndex(of: track)
    }

    private var nextIndex: Int? {
        switch playbackMode {
        case .sequential:
            guard let index else { return nil }
            let nextIndex = index + 1

            guard nextIndex < playlist.endIndex else { return nil }
            return nextIndex
        case .loop:
            guard let index else { return nil }
            return (index + 1) % playlist.count
        case .shuffle:
            return randomIndex()
        }
    }

    private var previousIndex: Int? {
        switch playbackMode {
        case .sequential:
            guard let index else { return nil }
            let previousIndex = index - 1

            guard previousIndex >= 0 else { return nil }
            return previousIndex
        case .loop:
            guard let index else { return nil }
            return (index + playlist.count - 1) % playlist.count
        case .shuffle:
            return randomIndex()
        }
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
    func randomIndex() -> Int? {
        guard !playlist.isEmpty else { return nil }

        if let track, let index = playlist.firstIndex(of: track) {
            let indices = Array(playlist.indices).filter { $0 != index }
            return indices.randomElement()
        } else {
            return playlist.indices.randomElement()
        }
    }

    // MARK: Play

    func play(track: Track) {
        addToPlaylist(urls: [track.url])

        self.track = track
        player.play(track)
    }

    func play(url: URL) {
        Task {
            if let track = await Track(url: url) {
                play(track: track)
            }
        }
    }

    // MARK: Playlist

    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }

            Task {
                if let track = await Track(url: url) {
                    addToPlaylist(tracks: [track])
                }
            }
        }
    }

    func addToPlaylist(tracks: [Track]) {
        for track in tracks {
            guard !playlist.contains(track) else { continue }
            playlist.append(track)
        }
    }

    func removeFromPlaylist(urls: [URL]) {
        for url in urls {
            if let index = playlist.firstIndex(where: { $0.url == url }) {
                if track?.url == url {
                    player.stop()
                    track = nil
                }
                playlist.remove(at: index)
            }
        }
    }

    func removeFromPlaylist(tracks: [Track]) {
        removeFromPlaylist(urls: tracks.map(\.url))
    }

    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlist.move(fromOffsets: indices, toOffset: destination)
    }

    func removeAll() {
        removeFromPlaylist(tracks: playlist)
    }

    // MARK: Convenient Functions

    func play() {
        if isRunning {
            player.play()
        } else if let track {
            play(track: track)
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
        guard let nextIndex else {
            stop()
            return
        }

        play(track: playlist[nextIndex])
    }

    func playPreviousTrack() {
        guard let previousIndex else {
            stop()
            return
        }

        play(track: playlist[previousIndex])
    }

    // MARK: Engine

    private func setupEngine() {
        player.withEngine { [weak self] engine in
            guard let self else { return }

            // Audio visualization
            let inputNode = engine.mainMixerNode
            let bus = 0
            let format = inputNode.outputFormat(forBus: bus)

            analyzer = RealtimeAnalyzer(fftSize: Int(Self.bufferSize))

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
                if let track = self.track {
                    // Plays again
                    self.play(track: track)
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
                track = playlist.first { $0.url == url }
            }

            updatePlaybackState()
            updateNowPlayingMetadataInfo(from: track)
            updateNowPlayingState(with: playbackState)
            updateNowPlayingInfo(with: playbackState)
        }
    }

    nonisolated func audioPlayer(_: AudioPlayer, playbackStateChanged playbackState: AudioPlayer.PlaybackState) {
        Task { @MainActor in
            updatePlaybackState()
            updateNowPlayingMetadataInfo(from: track)
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
