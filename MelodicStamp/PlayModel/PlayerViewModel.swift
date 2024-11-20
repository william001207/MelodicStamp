//
//  PlayerViewModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import Combine
import CAAudioHardware
import SFBAudioEngine
import os.log


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
        UserDefaults.standard.set(urls, forKey: "playlistURLs")
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
        if let url = decoder.inputSource.url, let index = playlist.firstIndex(where: { $0.url == url }) {
            let nextIndex = playlist.index(after: index)
            if playlist.indices.contains(nextIndex) {
                do {
                    if let decoder = try playlist[nextIndex].decoder() {
                        try player.enqueue(decoder)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.handleError(error)
                    }
                }
            }
        }
    }
    
    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        DispatchQueue.main.async {
            if let url = audioPlayer.nowPlaying?.inputSource.url {
                self.nowPlaying = self.playlist.first(where: { $0.url == url })
            } else {
                self.nowPlaying = nil
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
