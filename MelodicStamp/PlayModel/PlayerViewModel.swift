//
//  PlayerViewModel.swift
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

enum PlaybackMode: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case sequential = "顺序播放"
    case loop = "列表循环"
    case singleLoop = "单曲循环"
    case shuffle = "随机播放"
}

class PlayerViewModel: NSObject, ObservableObject {
    let player = AudioPlayer()
    
    @Published var playlist: [PlaylistItem] = []
    @Published var nowPlaying: PlaylistItem?
    @Published var outputDevices: [AudioDevice] = []
    @Published var selectedDevice: AudioDevice?
    
    @Published var progress: Double = 0.0
    @Published var elapsed: Double = 0.0
    @Published var remaining: Double = 0.0
    
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showSecondWindow: Bool = false
    
    @Published var playbackMode: PlaybackMode = .sequential
    
    @Published var isMuted: Bool = false {
        didSet {
            if isMuted {
                do {
                    try player.setVolume(0)
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    @Published var volume: Float = 1.0 {
        didSet {
            isMuted = false
            do {
                try player.setVolume(volume)
            } catch {
                handleError(error)
            }
        }
    }
    
    var speakerImage: Image {
        guard !isMuted else { return .init(systemSymbol: .speakerSlashFill) }
        
        return .init(systemSymbol: .speakerWave3Fill, variableValue: Double(volume))
    }
    
    private var timer: Timer?
    
    override init() {
        super.init()
        player.delegate = self
        loadPlaylist()
        updateDeviceMenu()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
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
        // TODO: 使用 Defaults 管理用户配置文件
        // UserDefaults.standard.set(urls, forKey: "playlistURLs")
    }
    
    func play(_ url: URL) {
        addToPlaylist(urls: [url])
        if let item = playlist.first(where: { $0.url == url }) {
            play(item: item)
        }
    }
    
    func play(item: PlaylistItem) {
        do {
            if let decoder = try item.decoder() {
                try player.play(decoder)
                nowPlaying = item
            }
        } catch {
            handleError(error)
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
                if nowPlaying?.url == url {
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
            handleError(error)
        }
    }
    
    func setOutputDevice(_ device: AudioDevice) {
        do {
            try player.setOutputDeviceID(device.objectID)
            selectedDevice = device
            // TODO: 使用 Defaults 管理用户配置文件
            //UserDefaults.standard.set(device.uid, forKey: "deviceUID")
        } catch {
            handleError(error)
        }
    }
    
    func togglePlayPause() throws {
        try player.togglePlayPause()
    }
    
    func seekForward() {
        player.seekForward()
    }
    
    func seekBackward() {
        player.seekBackward()
    }
    
    func seek(position: Double) {
        player.seek(position: position)
    }
    
    func nextTrack() {
        guard !playlist.isEmpty else { return }
        guard let current = nowPlaying else { return }

        if playbackMode == .singleLoop {
            play(item: current)
            return
        }

        if playbackMode == .sequential {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                let nextIndex = currentIndex + 1
                if playlist.indices.contains(nextIndex) {
                    play(item: playlist[nextIndex])
                } else {
                    player.stop()
                    nowPlaying = nil
                }
            }
        } else if playbackMode == .loop {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                let nextIndex = (currentIndex + 1) % playlist.count
                play(item: playlist[nextIndex])
            }
        } else if playbackMode == .shuffle {
            playRandomItem(exclude: current)
        }
    }

    func previousTrack() {
        guard !playlist.isEmpty else { return }
        guard let current = nowPlaying else { return }

        if playbackMode == .singleLoop {
            play(item: current)
            return
        }

        if playbackMode == .sequential {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                let prevIndex = currentIndex - 1
                if playlist.indices.contains(prevIndex) {
                    play(item: playlist[prevIndex])
                } else {
                    player.stop()
                    nowPlaying = nil
                }
            }
        } else if playbackMode == .loop {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                let prevIndex = (currentIndex - 1 + playlist.count) % playlist.count
                play(item: playlist[prevIndex])
            }
        } else if playbackMode == .shuffle {
            playRandomItem(exclude: current)
        }
    }

    func canNavigatePrevious() -> Bool {
        guard let current = nowPlaying else { return false }

        if playbackMode == .singleLoop {
            return true
        }

        if playbackMode == .sequential {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                return currentIndex > 0
            }
            return false
        }

        if playbackMode == .loop || playbackMode == .shuffle {
            return !playlist.isEmpty
        }

        return false
    }

    func canNavigateNext() -> Bool {
        guard let current = nowPlaying else { return false }

        if playbackMode == .singleLoop {
            return true
        }

        if playbackMode == .sequential {
            if let currentIndex = playlist.firstIndex(where: { $0.id == current.id }) {
                return currentIndex < playlist.count - 1
            }
            return false
        }

        if playbackMode == .loop || playbackMode == .shuffle {
            return !playlist.isEmpty
        }

        return false
    }

    private func playRandomItem(exclude current: PlaylistItem) {
        let remainingItems = playlist.filter { $0.id != current.id }
        if let randomItem = remainingItems.randomElement() {
            play(item: randomItem)
        } else {
            // 如果只有一个曲目，重复播放当前曲目
            play(item: current)
        }
    }
    
    func analyzeFiles(urls: [URL]) {
        do {
            let rg = try ReplayGainAnalyzer.analyzeAlbum(urls)
            os_log("Album gain %.2f dB, peak %.8f; Tracks: [%{public}@]", log: OSLog.default, type: .info, rg.0.gain, rg.0.peak, rg.1.map { (url, replayGain) in
                String(format: "\"%@\" gain %.2f dB, peak %.8f", FileManager.default.displayName(atPath: url.lastPathComponent), replayGain.gain, replayGain.peak)
            }.joined(separator: ", "))
            // TODO: 可以在此处添加通知用户分析完成的逻辑
        } catch {
            handleError(error)
        }
    }
    
    func exportWAVEFile(url: URL) {
        let destURL = url.deletingPathExtension().appendingPathExtension("wav")
        if FileManager.default.fileExists(atPath: destURL.path) {
            // TODO: 处理覆盖逻辑留给视图
            return
        }
        
        do {
            try AudioConverter.convert(url, to: destURL)
            try? AudioFile.copyMetadata(from: url, to: destURL)
        } catch {
            try? FileManager.default.trashItem(at: destURL, resultingItemURL: nil)
            handleError(error)
        }
    }
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.updatePlaybackInfo()
        }
    }
    
    private func updatePlaybackInfo() {
        guard let time = player.time else { return }
        if let progress = time.progress {
            self.progress = progress
        }
        if let current = time.current {
            self.elapsed = current
        }
        if let remaining = time.remaining {
            self.remaining = -remaining
        }
    }
}

extension PlayerViewModel: AudioPlayer.Delegate {
    
    func audioPlayer(_ audioPlayer: AudioPlayer, decodingComplete decoder: PCMDecoding) {
        // 尝试将 decoder 转换为具体类型
        if let audioDecoder = decoder as? AudioDecoder,
           let url = audioDecoder.inputSource.url,
           let index = playlist.firstIndex(where: { $0.url == url }) {

            switch playbackMode {
            case .singleLoop:
                // 单曲循环：重新播放当前曲目
                do {
                    if let currentDecoder = try playlist[index].decoder() {
                        try player.enqueue(currentDecoder)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.handleError(error)
                    }
                }

            case .sequential:
                // 顺序播放：跳转到下一首
                let nextIndex = playlist.index(after: index)
                if playlist.indices.contains(nextIndex) {
                    do {
                        if let nextDecoder = try playlist[nextIndex].decoder() {
                            try player.enqueue(nextDecoder)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.handleError(error)
                        }
                    }
                } else {
                    nextTrack() // 或者处理播放列表结束的逻辑
                }

            case .shuffle:
                // 随机播放：选择随机曲目
                let randomIndex = playlist.indices.randomElement()!
                do {
                    if let randomDecoder = try playlist[randomIndex].decoder() {
                        try player.enqueue(randomDecoder)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.handleError(error)
                    }
                }

            case .loop:
                // 列表循环：播放下一首，如果是最后一首，则从第一首开始
                let nextIndex = playlist.index(after: index)
                let loopIndex = nextIndex % playlist.count
                do {
                    if let loopDecoder = try playlist[loopIndex].decoder() {
                        try player.enqueue(loopDecoder)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.handleError(error)
                    }
                }
            }
        } else {
            os_log("Failed to cast decoder to AudioDecoder or retrieve URL", log: OSLog.default, type: .error)
        }
    }
    
    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        DispatchQueue.main.async {
            if let nowPlayingDecoder = audioPlayer.nowPlaying as? PCMDecoding,
               let audioDecoder = nowPlayingDecoder as? AudioDecoder,
               let url = audioDecoder.inputSource.url {
                self.nowPlaying = self.playlist.first(where: { $0.url == url })
            } else {
                self.nowPlaying = nil
                self.nextTrack()
            }
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, encounteredError error: Error) {
        audioPlayer.stop()
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}

extension PlayerViewModel {
    @discardableResult
    func adjustProgress(delta: CGFloat = 0.01, multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        let adjustedMultiplier = switch sign {
        case .plus:
            multiplier
        case .minus:
            -multiplier
        }
        let newProgress = self.progress + delta * adjustedMultiplier
        self.progress = max(0, min(1, newProgress))
        
        // 调用 playerViewModel.seek 更新位置
        seek(position: self.progress)
        
        return newProgress >= 0 && newProgress <= 1
    }
    
    @discardableResult
    func adjustTime(delta: Duration = .seconds(1), multiplier: CGFloat = 1, sign: FloatingPointSign = .plus) -> Bool {
        guard remaining > 0 else { return false }
        let deltaValue = CGFloat(delta.components.seconds) / CGFloat(remaining)
        return adjustProgress(delta: deltaValue, multiplier: multiplier, sign: sign)
    }
    
    @discardableResult func adjustVolume(delta: Float = 0.01, multiplier: Float = 1, sign: FloatingPointSign = .plus) -> Bool {
        let multiplier = switch sign {
        case .plus:
            multiplier
        case .minus:
            -multiplier
        }
        let volume = self.volume + delta * multiplier
        self.volume = max(0, min(1, volume))
        
        return volume >= 0 && volume <= 1
    }

}
