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
}

// MARK: - Player Model

@Observable class PlayerModel: NSObject {
    private let player = AudioPlayer()
    
    private var playlist: [PlaylistItem] = []
    private var current: PlaylistItem?
    
    private var outputDevices: [AudioDevice] = []
    private var selectedDevice: AudioDevice?
    
//    var errorMessage: String?
//    var showError: Bool = false
//    var showSecondWindow: Bool = false
    
    var playbackMode: PlaybackMode = .sequential
    
    var duration: Duration { player.time?.total.map { .seconds($0) } ?? .zero }
    var timeElapsed: TimeInterval { player.time?.current ?? .zero }
    var timeRemaining: TimeInterval { player.time?.remaining ?? .zero }
    
    var progress: CGFloat {
        get {
            player.time?.progress ?? .zero
        }
        
        set {
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
    
    var currentURL: URL? {
        current?.url
    }
    
    var currentMetadata: AudioMetadata? {
        get {
            current?.metadata
        }
        
        set {
            guard var current, let newValue else { return }
            current.metadata = newValue
        }
    }
    
    override init() {
        super.init()
        player.delegate = self
        loadPlaylist()
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
    
    func loadPlaylist() {
        if let urls = UserDefaults.standard.object(forKey: "playlistURLs") as? [String] {
            for urlString in urls {
                if let url = URL(string: urlString) {
                    let item = PlaylistItem(url)
                    playlist.append(item)
                }
            }
        }
    }
    
    func savePlaylist() {
        let urls = playlist.map { $0.url.absoluteString }
        // TODO: use `Defaults`
        // UserDefaults.standard.set(urls, forKey: "playlistURLs")
    }
    
    func play(_ url: URL) {
        addToPlaylist(urls: [url])
        if let item = playlist.first(where: { $0.url == url }) {
            play(item)
        }
    }
    
    func play(_ item: PlaylistItem) {
        do {
            if let decoder = try item.decoder() {
                try player.play(decoder)
                current = item
            }
        } catch {
//            handleError(error)
        }
    }
    
    func addToPlaylist(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }
            let item = PlaylistItem(url)
            playlist.append(item)
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
//            handleError(error)
        }
    }
    
    func setOutputDevice(_ device: AudioDevice) {
        do {
            try player.setOutputDeviceID(device.objectID)
            selectedDevice = device
            // TODO: use `Defaults`
            //UserDefaults.standard.set(device.uid, forKey: "deviceUID")
        } catch {
//            handleError(error)
        }
    }
    
    func togglePlayPause() {
        do {
            try player.togglePlayPause()
        } catch {
//            handleError(error)
        }
    }
    
    func nextTrack() {
        guard let nextIndex else { return }
        play(playlist[nextIndex])
    }

    func previousTrack() {
        guard let previousIndex else { return }
        play(playlist[previousIndex])
    }
    
    func analyzeFiles(urls: [URL]) {
        do {
            let rg = try ReplayGainAnalyzer.analyzeAlbum(urls)
            os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { (url, replayGain) in
                String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
            }.joined(separator: ", "))
            // TODO: notice user we're done
        } catch {
//            handleError(error)
        }
    }
    
    func exportWAVEFile(url: URL) {
        let destURL = url.deletingPathExtension().appendingPathExtension("wav")
        if FileManager.default.fileExists(atPath: destURL.path) {
            // TODO: handle this
            return
        }
        
        do {
            try AudioConverter.convert(url, to: destURL)
            try? AudioFile.copyMetadata(from: url, to: destURL)
        } catch {
            try? FileManager.default.trashItem(at: destURL, resultingItemURL: nil)
//            handleError(error)
        }
    }
    
//    func handleError(_ error: Error) {
//        DispatchQueue.main.async {
//            self.errorMessage = error.localizedDescription
//            self.showError = true
//        }
//    }
}

extension PlayerModel: AudioPlayer.Delegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, decodingComplete decoder: PCMDecoding) {
        if
            let audioDecoder = decoder as? AudioDecoder,
            let url = audioDecoder.inputSource.url,
            let index = playlist.firstIndex(where: { $0.url == url })
        {

            switch playbackMode {
            case .single:
                // single: play again
                do {
                    if let currentDecoder = try playlist[index].decoder() {
                        try player.enqueue(currentDecoder)
                    }
                } catch {
//                    DispatchQueue.main.async {
//                        self.handleError(error)
//                    }
                }

            case .sequential:
                // sequential: jump to next track
                let nextIndex = playlist.index(after: index)
                if playlist.indices.contains(nextIndex) {
                    do {
                        if let nextDecoder = try playlist[nextIndex].decoder() {
                            try player.enqueue(nextDecoder)
                        }
                    } catch {
//                        DispatchQueue.main.async {
//                            self.handleError(error)
//                        }
                    }
                } else {
                    nextTrack()
                }

            case .shuffle:
                // random
                let randomIndex = playlist.indices.randomElement()!
                do {
                    if let randomDecoder = try playlist[randomIndex].decoder() {
                        try player.enqueue(randomDecoder)
                    }
                } catch {
//                    DispatchQueue.main.async {
//                        self.handleError(error)
//                    }
                }

            case .loop:
                // playlist: jump to next track
                let nextIndex = playlist.index(after: index)
                let loopIndex = nextIndex % playlist.count
                do {
                    if let loopDecoder = try playlist[loopIndex].decoder() {
                        try player.enqueue(loopDecoder)
                    }
                } catch {
//                    DispatchQueue.main.async {
//                        self.handleError(error)
//                    }
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
               let url = audioDecoder.inputSource.url {
                self.current = self.playlist.first(where: { $0.url == url })
            } else {
                self.current = nil
                self.nextTrack()
            }
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, encounteredError error: Error) {
        audioPlayer.stop()
//        DispatchQueue.main.async {
//            self.handleError(error)
//        }
    }
}

extension PlayerModel {
    var speakerImage: Image {
        guard !isMuted else { return .init(systemSymbol: .speakerSlashFill) }
        return .init(systemSymbol: .speakerWave3Fill, variableValue: volume)
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
    
    @discardableResult func adjustTime(delta: Duration = .seconds(1), multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        guard duration > .zero else { return false }
        let deltaValue = CGFloat(delta.components.seconds) / CGFloat(duration.components.seconds)
        return adjustProgress(delta: deltaValue, multiplier: multiplier, sign: sign)
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
