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

@Observable final class PlayerModel: NSObject {
    static let bufferSize: AVAudioFrameCount = 2048

    // MARK: Player

    private var player: any Player

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
    private let timer = TimerPublisher(interval: 0.1)

    private var visualizationDataSubject = PassthroughSubject<AVAudioPCMBuffer?, Never>()
    var visualizationDataPublisher: AnyPublisher<AVAudioPCMBuffer?, Never> { visualizationDataSubject.eraseToAnyPublisher() }

    // MARK: Playlist & Playback

    private(set) var track: Track?
    private(set) var playlist: [Track] = []

    var playbackMode: PlaybackMode = Defaults[.defaultPlaybackMode]
    var playbackLooping: Bool = false

    private(set) var playbackTime: PlaybackTime?
    var unwrappedPlaybackTime: PlaybackTime { playbackTime ?? .init() }

    // MARK: Responsive Fields

    var progress: CGFloat {
        get {
            unwrappedPlaybackTime.progress
        }

        set {
            player.seekProgress(to: newValue)
            updateNowPlayingInfo()
        }
    }

    var time: TimeInterval {
        get {
            unwrappedPlaybackTime.elapsed
        }

        set {
            player.seekTime(to: newValue)
            updateNowPlayingInfo()
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
                playbackTime: do {
                    if let updated = player.playbackTime {
                        guard self.playbackTime != updated else { break playbackTime }
                        self.playbackTime = updated
                    } else {
                        self.playbackTime = nil
                    }
                }

                volume: do {
                    let updated = player.playbackVolume

                    guard self._volume != updated else { break volume }
                    self._volume = updated
                }

                isPlaying: do {
                    let updated = player.isPlaying

                    guard self._isPlaying != updated else { break isPlaying }
                    self._isPlaying = updated
                }

                isRunning: do {
                    let updated = player.isRunning

                    guard self.isRunning != updated else { break isRunning }
                    self.isRunning = updated
                }

                isMuted: do {
                    let updated = player.isMuted

                    guard self._isMuted != updated else { break isMuted }
                    self._isMuted = updated
                }

                self.updateOutputDevices()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Functions

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

        Task { @MainActor in
            self.track = track
            player.play(track)
        }
    }

    func play(url: URL) {
        if let track = Track(url: url) {
            play(track: track)
        }
    }

    // MARK: Playlist

    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }

            if let track = Track(url: url) {
                addToPlaylist(tracks: [track])
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

            inputNode.removeTap(onBus: bus)
            inputNode.installTap(onBus: bus, bufferSize: Self.bufferSize, format: format) { [weak self] buffer, _ in
                guard let strongSelf = self else { return }
                guard strongSelf.player.isPlaying else { return }

                buffer.frameLength = Self.bufferSize
                Task { @MainActor in
                    strongSelf.visualizationDataSubject.send(buffer)
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
    func playerDidFinishPlaying(_: some Melodic_Stamp.Player) {
        DispatchQueue.main.async {
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
    func audioPlayer(_: AudioPlayer, nowPlayingChanged nowPlaying: (any PCMDecoding)?) {
        DispatchQueue.main.async {
            // Updates track, otherwise keeps it
            if let nowPlaying,
               let audioDecoder = nowPlaying as? AudioDecoder,
               let url = audioDecoder.inputSource.url {
                self.track = self.playlist.first { $0.url == url }
            }

            self.updateNowPlayingState()
            self.updateNowPlayingInfo()
            self.updateNowPlayingMetadataInfo()
        }
    }

    func audioPlayer(_: AudioPlayer, playbackStateChanged _: AudioPlayer.PlaybackState) {
        DispatchQueue.main.async {
            self.updateNowPlayingState()
            self.updateNowPlayingInfo()
            self.updateNowPlayingMetadataInfo()
        }
    }

    func audioPlayer(_: AudioPlayer, encounteredError error: Error) {
        stop()
        print(error)
    }
}
