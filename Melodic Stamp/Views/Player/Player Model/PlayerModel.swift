//
//  PlayerModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import Combine
import SFSafeSymbols
import CAAudioHardware
import SFBAudioEngine
import os.log

// MARK: - Playback Mode

enum PlaybackMode: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
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

@Observable class PlayerModel: NSObject {
    private let player = AudioPlayer()
    
    private var outputDevices: [AudioDevice] = []
    private var selectedDevice: AudioDevice?
    
    private(set) var current: PlaylistItem?
    var playlist: [PlaylistItem] = []
    var playbackMode: PlaybackMode = .sequential
    
    var duration: Duration { player.time?.total.map { .seconds($0) } ?? .zero }
    var timeElapsed: TimeInterval { player.time?.current ?? .zero }
    var timeRemaining: TimeInterval { player.time?.remaining ?? .zero }
    
    var progress: CGFloat {
        get {
            player.time?.progress ?? .zero
        }
        
        set {
            // debounce and cancel if adjustment is smaller than 0.1s
            let difference = abs(newValue - progress)
            let timeDifference = duration.toTimeInterval() * difference
            guard timeDifference >= 1 / 10 else { return }
            
            player.seek(position: max(0, min(1, newValue)))
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
            } catch {
//                handleError(error)
            }
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
            } catch {
//                handleError(error)
            }
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
        updateDeviceMenu()
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
    
    func play(url: URL) {
        addToPlaylist(urls: [url])
        
        if let item = playlist.first(where: { $0.url == url }) {
            play(item: item)
        }
    }
    
    func play(item: PlaylistItem) {
        do {
            if let decoder = try item.decoder() {
                try player.play(decoder)
                current = item
            }
        } catch {
            
        }
    }
    
    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }
            
            if let item = PlaylistItem(url: url) {
                playlist.append(item)
            }
        }
    }
    
    func removeFromPlaylist(urls: [URL]) {
        for url in urls {
            if let index = playlist.firstIndex(where: { $0.url == url }) {
                if current?.url == url {
                    player.stop()
                }
                playlist.remove(at: index)
            }
        }
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
        } catch {

        }
    }
    
    func setOutputDevice(_ device: AudioDevice) {
        do {
            try player.setOutputDeviceID(device.objectID)
            selectedDevice = device
        } catch {

        }
    }
    
    func play() {
        do {
            try player.play()
        } catch {
            
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayPause() {
        do {
            try player.togglePlayPause()
        } catch {

        }
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
            os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { (url, replayGain) in
                String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
            }.joined(separator: ", "))
            // TODO: notice user we're done
        } catch {

        }
    }
    
//    func exportWAVEFile(url: URL) {
//        let destURL = url.deletingPathExtension().appendingPathExtension("wav")
//        if FileManager.default.fileExists(atPath: destURL.path) {
//            // TODO: handle this
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
    func audioPlayer(_ audioPlayer: AudioPlayer, decodingComplete decoder: PCMDecoding) {
        if let audioDecoder = decoder as? AudioDecoder {
            switch playbackMode {
            case .single:
                // play again
                guard let currentIndex else { break }
                do {
                    if let decoder = try playlist[currentIndex].decoder() {
                        try player.enqueue(decoder)
                    }
                } catch {
                    
                }
            default:
                // jump to next track
                guard let nextIndex else { break }
                do {
                    if let decoder = try playlist[nextIndex].decoder() {
                        try player.enqueue(decoder)
                    }
                } catch {
                    
                }
            }
        } else {
            os_log("Failed to cast decoder to AudioDecoder or retrieve URL", log: OSLog.default, type: .error)
        }
    }
    
    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        DispatchQueue.main.async {
            if let nowPlayingDecoder = audioPlayer.nowPlaying,
               let audioDecoder = nowPlayingDecoder as? AudioDecoder,
               let url = audioDecoder.inputSource.url
            {
                self.current = self.playlist.first(where: { $0.url == url })
            } else {
                self.current = nil
                self.nextTrack()
            }
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, encounteredError error: Error) {
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
        if hasCurrentTrack && isPlaying {
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
        let progress = self.progress + delta * adjustedMultiplier
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
        let volume = self.volume + delta * multiplier
        self.volume = volume
        
        return volume >= 0 && volume <= 1
    }
}

extension PlayerModel {
    static func splitArtists(from artist: String) -> [Substring] {
        artist.split(separator: /[\/,]\s*/)
    }
}
