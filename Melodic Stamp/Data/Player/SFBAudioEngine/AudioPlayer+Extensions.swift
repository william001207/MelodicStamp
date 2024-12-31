//
//  AudioPlayer+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation
import SFBAudioEngine

struct SFBAudioPlayer: Player {
    private var player: AudioPlayer
    private var mutedVolume: CGFloat = .zero
    
    var isPlaying: Bool { player.isPlaying }
    private(set) var isMuted: Bool = false
    
    var playbackTime: PlaybackTime? {
        player.time.flatMap {
            guard let total = $0.total, let current = $0.current else { return nil }
            return .init(duration: total.duration, elapsed: current)
        }
    }
    
    var playbackVolume: CGFloat {
        .init(player.volume)
    }
    
    mutating func play(_ item: PlayableItem) {
        do {
            if let decoder = try Self.decoder(for: item) {
                try player.play(decoder)
            }
        } catch {
            print(error)
        }
    }
    
    mutating func enqueue(_ item: PlayableItem) {
        do {
            if let decoder = try Self.decoder(for: item) {
                try player.enqueue(decoder)
            }
        } catch {
            print(error)
        }
    }
    
    mutating func play() {
        do {
            try player.play()
        } catch {
            print(error)
        }
    }
    
    mutating func pause() {
        player.pause()
    }
    
    mutating func stop() {
        player.stop()
    }
    
    mutating func mute() {
        isMuted = true
        mutedVolume = playbackVolume
        seekVolume(to: .zero)
    }
    
    mutating func unmute() {
        isMuted = false
        seekVolume(to: mutedVolume)
    }
    
    mutating func seekTime(to time: TimeInterval) {
        player.seek(time: time)
    }
    
    mutating func seekProgress(to progress: CGFloat) {
        player.seek(position: Double(progress))
    }
    
    mutating func seekVolume(to volume: CGFloat) {
        do {
            try player.setVolume(Float(volume))
        } catch {
            print(error)
        }
    }
}

extension SFBAudioPlayer {
    static func decoder(for item: PlayableItem, enablesDoP: Bool = false) throws -> PCMDecoding? {
        let url = item.url
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }

        let pathExtension = url.pathExtension.lowercased()
        if AudioDecoder.handlesPaths(withExtension: pathExtension) {
            return try AudioDecoder(url: url)
        } else if DSDDecoder.handlesPaths(withExtension: pathExtension) {
            let dsdDecoder = try DSDDecoder(url: url)
            return enablesDoP ? try DoPDecoder(decoder: dsdDecoder) : try DSDPCMDecoder(decoder: dsdDecoder)
        } else {
            return nil
        }
    }
}
