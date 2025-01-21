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
import MediaPlayer
import os.log
import SFBAudioEngine
import SFSafeSymbols
import SwiftUI

// MARK: - Fields

@Observable final class PlayerModel: NSObject {
    // MARK: Player

    private var player: any Player

    // Do not use computed variables for the sake of correctly updating view data
    private(set) var outputDevices: [AudioDevice] = []
    private(set) var defaultOutputDevice: AudioDevice?
    private(set) var defaultSystemOutputDevice: AudioDevice?

    private(set) var isUsingSystemOutputDevice: Bool = false
    private var _selectedOutputDevice: AudioDevice?

    private var analyzer: RealtimeAnalyzer!

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

    private var visualizationDataSubject = PassthroughSubject<[[Float]], Never>()
    var visualizationDataPublisher: AnyPublisher<[[Float]], Never> { visualizationDataSubject.eraseToAnyPublisher() }

    // MARK: Playlist & Playback

    private(set) var track: Track?
    private(set) var playlist: [Track] = []

    var playbackMode: PlaybackMode = Defaults[.defaultPlaybackMode]
    var playbackLooping: Bool = false

    private(set) var playbackTime: PlaybackTime?
    var unwrappedPlaybackTime: PlaybackTime { playbackTime ?? .init() }

    // MARK: FFT

    private var audioDataBuffer: [CGFloat] = []

    // MARK: Responsive

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

    var hasCurrentTrack: Bool {
        track != nil
    }

    var hasNextTrack: Bool {
        guard track != nil else { return false }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return false }
            return currentIndex < playlist.count - 1
        case .loop, .shuffle:
            return !playlist.isEmpty
        }
    }

    var hasPreviousTrack: Bool {
        guard track != nil else { return false }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return false }
            return currentIndex > 0
        case .loop, .shuffle:
            return !playlist.isEmpty
        }
    }

    var currentIndex: Int? {
        guard let track else { return nil }
        return playlist.firstIndex(of: track)
    }

    var nextIndex: Int? {
        guard hasNextTrack else { return nil }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return nil }
            return currentIndex + 1
        case .loop:
            guard let currentIndex else { return nil }
            return (currentIndex + 1) % playlist.count
        case .shuffle:
            return randomIndex()
        }
    }

    var previousIndex: Int? {
        guard hasPreviousTrack else { return nil }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return nil }
            return currentIndex - 1
        case .loop:
            guard let currentIndex else { return nil }
            return (currentIndex + playlist.count - 1) % playlist.count
        case .shuffle:
            return randomIndex()
        }
    }

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

    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlist.move(fromOffsets: indices, toOffset: destination)
    }

    func removeFromPlaylist(tracks: [Track]) {
        removeFromPlaylist(urls: tracks.map(\.url))
    }

    func removeAll() {
        removeFromPlaylist(tracks: playlist)
    }

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

    func nextTrack() {
        guard let nextIndex else {
            stop()
            return
        }

        play(track: playlist[nextIndex])
    }

    func previousTrack() {
        guard let previousIndex else {
            stop()
            return
        }

        play(track: playlist[previousIndex])
    }

    private func setupEngine() {
        /*
        player.withEngine { [weak self] engine in
            guard let self else { return }

            // Audio visualization
            let inputNode = engine.mainMixerNode
            let bus = 0

            let format = inputNode.outputFormat(forBus: bus)
            let sampleRate = format.sampleRate

            inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
                self.analyzer = RealtimeAnalyzer(fftSize: 1024)
                self.processAudioBuffer(buffer, sampleRate: Float(sampleRate))
            }
        }
        */

        player.withEngine { [weak self] engine in
            guard let self else { return }

            // Audio visualization
            let inputNode = engine.mainMixerNode
            let bus = 0
            let format = inputNode.outputFormat(forBus: bus)
            let bufferSize = 2048

            self.analyzer = RealtimeAnalyzer(fftSize: bufferSize)

            inputNode.removeTap(onBus: bus)

            inputNode.installTap(onBus: bus, bufferSize: AVAudioFrameCount(bufferSize), format: format) { [weak self] buffer, when in
                guard let strongSelf = self else { return }
                if !strongSelf.player.isPlaying { return }

                buffer.frameLength = AVAudioFrameCount(bufferSize)

                let spectra = strongSelf.analyzer.analyse(with: buffer)
                
                Task { @MainActor in
                    strongSelf.visualizationDataSubject.send(spectra)
                }
            }
        }
    }
}

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

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Float) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataPointer = channelData[0]
        let frameLength = Int(buffer.frameLength)

        audioDataBuffer = Array(UnsafeBufferPointer(start: channelDataPointer, count: frameLength)).map(CGFloat.init)

        Task { @MainActor in
            let fftMagnitudes = await FFTHelper.perform(audioDataBuffer.map(Float.init), sampleRate: sampleRate)
            self.visualizationDataSubject.send(fftMagnitudes.map(CGFloat.init))
        }
    }
    */

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
                self.nextTrack()
            }
        }
    }
}

extension PlayerModel: AudioPlayer.Delegate {
    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        DispatchQueue.main.async {
            // Updates track, otherwise keeps it
            if let nowPlayingDecoder = audioPlayer.nowPlaying,
               let audioDecoder = nowPlayingDecoder as? AudioDecoder,
               let url = audioDecoder.inputSource.url {
                self.track = self.playlist.first { $0.url == url }
            }

            self.updateNowPlayingState()
            self.updateNowPlayingInfo()
            self.updateNowPlayingMetadataInfo()
        }
    }

    func audioPlayerPlaybackStateChanged(_: AudioPlayer) {
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

extension PlayerModel {
    var speakerImage: Image {
        if isMuted {
            Image(systemSymbol: .speakerSlashFill)
        } else {
            Image(systemSymbol: .speakerWave3Fill, variableValue: volume)
        }
    }

    var playPauseImage: Image {
        if isPlayable, isPlaying {
            Image(systemSymbol: .pauseFill)
        } else {
            Image(systemSymbol: .playFill)
        }
    }

    @discardableResult func adjustProgress(delta: CGFloat = 0.01, multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        let adjustedMultiplier = switch sign {
        case .plus:
            multiplier
        case .minus:
            -multiplier
        }
        let progress = progress + delta * adjustedMultiplier
        self.progress = progress

        return progress >= 0 && progress <= 1
    }

    @discardableResult func adjustTime(delta: TimeInterval = 1, multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        guard unwrappedPlaybackTime.duration > .zero else { return false }
        return adjustProgress(
            delta: delta / TimeInterval(unwrappedPlaybackTime.duration),
            multiplier: multiplier, sign: sign
        )
    }

    @discardableResult func adjustVolume(delta: CGFloat = 0.01, multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        let multiplier = switch sign {
        case .plus:
            multiplier
        case .minus:
            -multiplier
        }
        let volume = volume + delta * multiplier
        self.volume = volume

        return volume >= 0 && volume <= 1
    }
}

extension PlayerModel {
    @objc func handleRouteChange(_: Notification) {}
}

extension PlayerModel {
    func updateNowPlayingState() {
        let infoCenter = MPNowPlayingInfoCenter.default()

        infoCenter.playbackState = if isPlayable {
            isPlaying ? .playing : .paused
        } else {
            .stopped
        }
    }

    func updateNowPlayingInfo() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var info = infoCenter.nowPlayingInfo ?? .init()

        if isPlayable {
            info[MPMediaItemPropertyPlaybackDuration] = TimeInterval(unwrappedPlaybackTime.duration)
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = unwrappedPlaybackTime.elapsed
        } else {
            info[MPMediaItemPropertyPlaybackDuration] = nil
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nil
        }

        infoCenter.nowPlayingInfo = info
    }

    func updateNowPlayingMetadataInfo() {
        if let track {
            track.metadata.updateNowPlayingInfo()
        } else {
            Metadata.resetNowPlayingInfo()
        }
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play
        commandCenter.playCommand.addTarget { [unowned self] _ in
            guard isPlayable else { return .noActionableNowPlayingItem }

            if isPlaying {
                return .commandFailed
            } else {
                play()
                return .success
            }
        }

        // Pause
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            guard isPlayable else { return .noActionableNowPlayingItem }

            if !isPlaying {
                return .commandFailed
            } else {
                pause()
                return .success
            }
        }

        // Toggle play pause
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
            guard isPlayable else { return .noActionableNowPlayingItem }

            togglePlayPause()
            return .success
        }

        // Skip forward
        commandCenter.skipForwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            guard isPlayable else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }

            adjustTime(delta: event.interval, sign: .plus)
            return .success
        }

        // Skip backward
        commandCenter.skipBackwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            guard isPlayable else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }

            adjustTime(delta: event.interval, sign: .minus)
            return .success
        }

        // Seek
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard isPlayable else { return .noActionableNowPlayingItem }
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }

            progress = event.positionTime / TimeInterval(unwrappedPlaybackTime.duration)
            return .success
        }

        // Next track
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            guard hasNextTrack else { return .noSuchContent }

            nextTrack()
            return .success
        }

        // Previous track
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            guard hasPreviousTrack else { return .noSuchContent }

            previousTrack()
            return .success
        }
    }
}
