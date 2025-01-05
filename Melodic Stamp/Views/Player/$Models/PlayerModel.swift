//
//  PlayerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import Accelerate
import CAAudioHardware
import Combine
import MediaPlayer
import os.log
import SFBAudioEngine
import SFSafeSymbols
import SwiftUI

// MARK: - Fields

@Observable final class PlayerModel: NSObject {
    typealias Player = MelodicStamp.Player

    // MARK: Player

    private var player: Player

    private var outputDevices: [AudioDevice] = []
    private var selectedDevice: AudioDevice?

    // MARK: Publishers

    private var cancellables = Set<AnyCancellable>()
    private let timer = TimerPublisher(interval: 0.1)

    private var playbackTimeSubject = PassthroughSubject<PlaybackTime?, Never>()
    private var isPlayingSubject = PassthroughSubject<Bool, Never>()
    private var visualizationDataSubject = PassthroughSubject<[CGFloat], Never>()

    var playbackTimePublisher: AnyPublisher<PlaybackTime?, Never> {
        playbackTimeSubject.eraseToAnyPublisher()
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }

    var visualizationDataPublisher: AnyPublisher<[CGFloat], Never> {
        visualizationDataSubject.eraseToAnyPublisher()
    }

    // MARK: Playlist & Playback

    private(set) var current: PlayableItem?
    private(set) var playlist: [PlayableItem] = []

    var playbackMode: PlaybackMode = .sequential
    var playbackLooping: Bool = false

    var playbackTime: PlaybackTime? { player.playbackTime }
    var unwrappedPlaybackTime: PlaybackTime {
        playbackTime ?? .init()
    }

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

    var volume: CGFloat {
        get {
            player.playbackVolume
        }

        set {
            player.seekVolume(to: newValue)
        }
    }

    var isPlaying: Bool {
        get {
            player.isPlaying
        }

        set {
            player.setPlaying(newValue)
        }
    }

    var isMuted: Bool {
        get {
            player.isMuted
        }

        set {
            player.setMuted(newValue)
        }
    }

    var isPlaylistEmpty: Bool {
        playlist.isEmpty
    }

    var hasCurrentTrack: Bool {
        current != nil
    }

    var hasNextTrack: Bool {
        guard current != nil else { return false }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return false }
            return currentIndex < playlist.count - 1
        case .loop, .shuffle:
            return !playlist.isEmpty
        }
    }

    var hasPreviousTrack: Bool {
        guard current != nil else { return false }

        switch playbackMode {
        case .sequential:
            guard let currentIndex else { return false }
            return currentIndex > 0
        case .loop, .shuffle:
            return !playlist.isEmpty
        }
    }

    var currentIndex: Int? {
        guard let current else { return nil }
        return playlist.firstIndex(of: current)
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

    init(_ player: Player) {
        self.player = player
        super.init()

        self.player.delegate = self

//        player.delegate = self
        setupRemoteTransportControls()
        setupEngine()

        timer
            .receive(on: DispatchQueue.main)
            .sink { _ in
                playbackTime: do {
                    if let playbackTime = self.playbackTime {
                        let duration = playbackTime.duration
                        let elapsed = playbackTime.elapsed

                        self.playbackTimeSubject.send(.init(
                            duration: duration, elapsed: elapsed
                        ))
                    } else {
                        self.playbackTimeSubject.send(nil)
                    }
                }

                isPlaying: do {
                    self.isPlayingSubject.send(self.isPlaying)
                }
            }
            .store(in: &cancellables)

        //        updateDeviceMenu()
    }
}

// MARK: - Functions

extension PlayerModel {
    func randomIndex() -> Int? {
        guard !playlist.isEmpty else { return nil }
        
        if let current, let index = playlist.firstIndex(of: current) {
            let indices = Array(playlist.indices).filter { $0 != index }
            return indices.randomElement()
        } else {
            return playlist.indices.randomElement()
        }
    }
    
    func play(item: PlayableItem) {
        addToPlaylist(urls: [item.url])
        
        Task { @MainActor in
            current = item
            player.play(item)
        }
    }
    
    func play(url: URL) {
        if let item = PlayableItem(url: url) {
            play(item: item)
        }
    }
    
    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }
            
            if let item = PlayableItem(url: url) {
                addToPlaylist(items: [item])
            }
        }
    }
    
    func addToPlaylist(items: [PlayableItem]) {
        for item in items {
            guard !playlist.contains(item) else { continue }
            playlist.append(item)
        }
    }
    
    func removeFromPlaylist(urls: [URL]) {
        for url in urls {
            if let index = playlist.firstIndex(where: { $0.url == url }) {
                if current?.url == url {
                    player.stop()
                    current = nil
                }
                playlist.remove(at: index)
            }
        }
    }
    
    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlist.move(fromOffsets: indices, toOffset: destination)
    }
    
    func removeFromPlaylist(items: [PlayableItem]) {
        removeFromPlaylist(urls: items.map(\.url))
    }
    
    func removeAll() {
        removeFromPlaylist(items: playlist)
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayPause() {
        player.togglePlaying()
    }
    
    func nextTrack() {
        guard let nextIndex else { return }
        play(item: playlist[nextIndex])
    }
    
    func previousTrack() {
        guard let previousIndex else { return }
        play(item: playlist[previousIndex])
    }
    
    private func setupEngine() {
        player.withEngine { [weak self] engine in
            guard let self else { return }
            
            // Audio visualization
            let inputNode = engine.mainMixerNode
            let bus = 0
            
            let format = inputNode.outputFormat(forBus: bus)
            let sampleRate = format.sampleRate
            
            inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
                self.processAudioBuffer(buffer, sampleRate: Float(sampleRate))
            }
        }
    }
}

extension PlayerModel {
    //    func analyzeFiles(urls: [URL]) {
    //        do {
    //            let rg = try ReplayGainAnalyzer.analyzeAlbum(urls)
    //            os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { url, replayGain in
    //                String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
    //            }.joined(separator: ", "))
    //            // TODO: Notice user we're done
    //        } catch {}
    //    }
    
    //    func exportWAVEFile(url: URL) {
    //        let destURL = url.deletingPathExtension().appendingPathExtension("wav")
    //        if FileManager.default.fileExists(atPath: destURL.path) {
    //            // TODO: Handle this
    //            return
    //        }
    //
    //        do {
    //            try AudioConverter.convert(url, to: destURL)
    //            try? AudioFile.copyMetadata(from: url, to: destURL)
    //        } catch {
    //            try? FileManager.default.trashItem(at: destURL, resultingItemURL: nil)
    //
    //        }
    //    }
    
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
    
//        func updateDeviceMenu() {
//            do {
//                outputDevices = try AudioDevice.devices.filter { try $0.supportsOutput }
//                if let uid = UserDefaults.standard.string(forKey: "deviceUID"),
//                   let deviceID = try? AudioSystemObject.instance.deviceID(forUID: uid),
//                   let device = outputDevices.first(where: { $0.objectID == deviceID }) {
//                    selectedDevice = device
//                    try? player.setOutputDeviceID(deviceID)
//                } else {
//                    selectedDevice = outputDevices.first
//                    if let device = selectedDevice {
//                        try? player.setOutputDeviceID(device.objectID)
//                    }
//                }
//            } catch {}
//        }
//    
//        func setOutputDevice(_ device: AudioDevice) {
//            do {
//                try player.setOutputDeviceID(device.objectID)
//                selectedDevice = device
//            } catch {}
//        }
}

extension PlayerModel: PlayerDelegate {
    func playerDidFinishPlaying(_ player: some MelodicStamp.Player) {
        let index = if playbackLooping {
            // Play again
            currentIndex
        } else {
            // Jump to next track
            nextIndex
        }

        guard let index, playlist.indices.contains(index) else { return }
        player.enqueue(playlist[index])
    }
}

extension PlayerModel: AudioPlayer.Delegate {
    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        DispatchQueue.main.async {
            if let nowPlayingDecoder = audioPlayer.nowPlaying,
               let audioDecoder = nowPlayingDecoder as? AudioDecoder,
               let url = audioDecoder.inputSource.url {
                self.current = self.playlist.first(where: { $0.url == url })
            } else {
                self.current = nil
                self.nextTrack()
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

    func audioPlayer(_ audioPlayer: AudioPlayer, encounteredError _: Error) {
        audioPlayer.stop()
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
        if hasCurrentTrack, isPlaying {
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
            delta: delta / unwrappedPlaybackTime.duration.timeInterval,
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
    func updateNowPlayingState() {
        let infoCenter = MPNowPlayingInfoCenter.default()

        infoCenter.playbackState = if hasCurrentTrack {
            isPlaying ? .playing : .paused
        } else {
            .stopped
        }
    }

    func updateNowPlayingInfo() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var info = infoCenter.nowPlayingInfo ?? .init()

        if hasCurrentTrack {
            info[MPMediaItemPropertyPlaybackDuration] = unwrappedPlaybackTime.duration.timeInterval
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = unwrappedPlaybackTime.elapsed
        } else {
            info[MPMediaItemPropertyPlaybackDuration] = nil
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nil
        }

        infoCenter.nowPlayingInfo = info
    }

    func updateNowPlayingMetadataInfo() {
        if let current {
            current.metadata.updateNowPlayingInfo()
        } else {
            Metadata.resetNowPlayingInfo()
        }
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play
        commandCenter.playCommand.addTarget { [unowned self] _ in
            guard hasCurrentTrack else { return .noActionableNowPlayingItem }

            if isPlaying {
                return .commandFailed
            } else {
                play()
                return .success
            }
        }

        // Pause
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            guard hasCurrentTrack else { return .noActionableNowPlayingItem }

            if !isPlaying {
                return .commandFailed
            } else {
                pause()
                return .success
            }
        }

        // Toggle play pause
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
            guard hasCurrentTrack else { return .noActionableNowPlayingItem }

            togglePlayPause()
            return .success
        }

        // Skip forward
        commandCenter.skipForwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            guard hasCurrentTrack else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }

            adjustTime(delta: event.interval, sign: .plus)
            return .success
        }

        // Skip backward
        commandCenter.skipBackwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            guard hasCurrentTrack else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }

            adjustTime(delta: event.interval, sign: .minus)
            return .success
        }

        // Seek
//        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
//            guard hasCurrentTrack else { return .noActionableNowPlayingItem }
//            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
//
//            progress = event.positionTime / duration.timeInterval
//            return .success
//        }

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
