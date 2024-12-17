//
//  PlayerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import CAAudioHardware
import Combine
import os.log
import SFBAudioEngine
import SFSafeSymbols
import SwiftUI
import MediaPlayer

// MARK: - Playback Mode

enum PlaybackMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case single
    case sequential
    case loop
    case shuffle

    var image: Image {
        switch self {
        case .single:
            .init(systemSymbol: .repeat1)
        case .sequential:
            .init(systemSymbol: .musicNoteList)
        case .loop:
            .init(systemSymbol: .repeat)
        case .shuffle:
            .init(systemSymbol: .shuffle)
        }
    }

    func cycle(negate: Bool = false) -> Self {
        switch self {
        case .single:
            negate ? .shuffle : .sequential
        case .sequential:
            negate ? .single : .loop
        case .loop:
            negate ? .sequential : .shuffle
        case .shuffle:
            negate ? .loop : .single
        }
    }
}

// MARK: - Player Model

@Observable final class PlayerModel: NSObject {
    private var player: AudioPlayer = .init()

    private var outputDevices: [AudioDevice] = []
    private var selectedDevice: AudioDevice?

    var undoManager: () -> UndoManager? = { nil }
    
    private(set) var current: PlaylistItem?
    var playlist: [PlaylistItem] = []
    var playbackMode: PlaybackMode = .sequential

    var lyricLines: [LRCLine] = []
    var currentLyricIndex: Int = 0

    var duration: Duration { player.time?.total.map { .seconds($0) } ?? .zero }
    var timeElapsed: TimeInterval { player.time?.current ?? .zero }
    var timeRemaining: TimeInterval { player.time?.remaining ?? .zero }

    var progress: CGFloat {
        get {
            player.time?.progress ?? .zero
        }

        set {
            // Debounce and cancel if adjustment is smaller than 0.09s
            let difference = abs(newValue - progress)
            let timeDifference = duration.toTimeInterval() * difference
            guard timeDifference > 9 / 100 else { return }

            player.seek(position: max(0, min(1, newValue)))
            updateNowPlayingInfo()
        }
    }

    private var mutedVolume: CGFloat = .zero
    var volume: CGFloat {
        get {
            if isMuted {
                mutedVolume
            } else {
                CGFloat(player.volume)
            }
        }

        set {
            isMuted = false
            do {
                try player.setVolume(Float(newValue))
            } catch {}
        }
    }

    var isPlaying: Bool {
        player.isPlaying
    }

    var isMuted: Bool = false {
        didSet {
            do {
                if isMuted {
                    mutedVolume = CGFloat(player.volume)
                    try player.setVolume(0)
                } else {
                    try player.setVolume(Float(mutedVolume))
                }
            } catch {}
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
        case .single:
            return true
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
        case .single:
            return true
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
        case .single:
            return currentIndex
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
        case .single:
            return currentIndex
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

    override init() {
        super.init()
        player.delegate = self
        setupRemoteTransportControls()
        //        updateDeviceMenu()
    }

    func randomIndex() -> Int? {
        guard !playlist.isEmpty else { return nil }

        if let current, let index = playlist.firstIndex(of: current) {
            let indices = Array(playlist.indices).filter { $0 != index }
            return indices.randomElement()
        } else {
            return playlist.indices.randomElement()
        }
    }

    func play(item: PlaylistItem) {
        addToPlaylist(urls: [item.url])

        Task {
            if let decoder = try item.decoder() {
                self.current = item
                try self.player.play(decoder)
            }
        }
    }

    func play(url: URL) {
        if let item = PlaylistItem(url: url) {
            play(item: item)
        }
    }

    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }

            if let item = PlaylistItem(url: url) {
                item.metadata.undoManager = undoManager
                addToPlaylist(items: [item])
            }
        }
    }

    func addToPlaylist(items: [PlaylistItem]) {
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

    func removeFromPlaylist(items: [PlaylistItem]) {
        removeFromPlaylist(urls: items.map(\.url))
    }

    func removeAll() {
        removeFromPlaylist(items: playlist)
    }

    func updateDeviceMenu() {
        do {
            outputDevices = try AudioDevice.devices.filter { try $0.supportsOutput }
            if let uid = UserDefaults.standard.string(forKey: "deviceUID"),
               let deviceID = try? AudioSystemObject.instance.deviceID(forUID: uid),
               let device = outputDevices.first(where: { $0.objectID == deviceID }) {
                selectedDevice = device
                try? player.setOutputDeviceID(deviceID)
            } else {
                selectedDevice = outputDevices.first
                if let device = selectedDevice {
                    try? player.setOutputDeviceID(device.objectID)
                }
            }
        } catch {}
    }

    func setOutputDevice(_ device: AudioDevice) {
        do {
            try player.setOutputDeviceID(device.objectID)
            selectedDevice = device
        } catch {}
    }

    func play() {
        do {
            try player.play()
        } catch {}
    }

    func pause() {
        player.pause()
    }

    func togglePlayPause() {
        do {
            try player.togglePlayPause()
        } catch {}
    }

    func nextTrack() {
        guard let nextIndex else { return }
        play(item: playlist[nextIndex])
    }

    func previousTrack() {
        guard let previousIndex else { return }
        play(item: playlist[previousIndex])
    }

    func analyzeFiles(urls: [URL]) {
        do {
            let rg = try ReplayGainAnalyzer.analyzeAlbum(urls)
            os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { url, replayGain in
                String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
            }.joined(separator: ", "))
            // TODO: Notice user we're done
        } catch {}
    }

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
}

extension PlayerModel: AudioPlayer.Delegate {
    func audioPlayer(_: AudioPlayer, decodingComplete decoder: PCMDecoding) {
        if let audioDecoder = decoder as? AudioDecoder {
            switch playbackMode {
            case .single:
                // Play again
                guard let currentIndex else { break }
                do {
                    if let decoder = try playlist[currentIndex].decoder() {
                        try player.enqueue(decoder)
                    }
                } catch {}
            default:
                // Jump to next track
                guard let nextIndex else { break }
                do {
                    if let decoder = try playlist[nextIndex].decoder() {
                        try player.enqueue(decoder)
                    }
                } catch {}
            }
        } else {
            os_log("Failed to cast decoder to AudioDecoder or retrieve URL", log: OSLog.default, type: .error)
        }
    }

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
    
    func audioPlayerPlaybackStateChanged(_ audioPlayer: AudioPlayer) {
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
        guard duration > .zero else { return false }
        return adjustProgress(delta: delta / duration.toTimeInterval(), multiplier: multiplier, sign: sign)
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
            info[MPMediaItemPropertyPlaybackDuration] = duration.toTimeInterval()
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeElapsed
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
        commandCenter.playCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            
            if self.isPlaying {
                return .commandFailed
            } else {
                self.play()
                return .success
            }
        }
        
        // Pause
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            
            if !self.isPlaying {
                return .commandFailed
            } else {
                self.pause()
                return .success
            }
        }
        
        // Toggle play pause
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            
            self.togglePlayPause()
            return .success
        }
        
        // Skip forward
        commandCenter.skipForwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            
            self.adjustTime(delta: event.interval, sign: .plus)
            return .success
        }
        
        // Skip backward
        commandCenter.skipBackwardCommand.preferredIntervals = [1.0, 5.0, 15.0]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            
            self.adjustTime(delta: event.interval, sign: .minus)
            return .success
        }
        
        // Seek
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard self.hasCurrentTrack else { return .noActionableNowPlayingItem }
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.progress = event.positionTime / duration.toTimeInterval()
            return .success
        }
        
        // Next track
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            guard self.hasNextTrack else { return .noSuchContent }
            
            self.nextTrack()
            return .success
        }
        
        // Previous track
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            guard self.hasPreviousTrack else { return .noSuchContent }
            
            self.previousTrack()
            return .success
        }
    }
}
