//
//  SFBAudioEngine+Player.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation
import SFBAudioEngine

class SFBAudioEnginePlayer: NSObject, Player {
    
    init(_ player: AudioPlayer = .init()) {
        self.player = player
        super.init()

        self.player.delegate = self
    }

    var delegate: (any PlayerDelegate)?

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

    func play(_ item: PlayableItem) {
        do {
            if let decoder = try Self.decoder(for: item) {
                try player.play(decoder)
            }
        } catch {
            print(error)
        }
    }

    func enqueue(_ item: PlayableItem) {
        do {
            if let decoder = try Self.decoder(for: item) {
                try player.enqueue(decoder)
            }
        } catch {
            print(error)
        }
    }

    func play() {
        do {
            try player.play()
        } catch {
            print(error)
        }
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop()
    }

    func mute() {
        isMuted = true
        mutedVolume = playbackVolume
        seekVolume(to: .zero)
    }

    func unmute() {
        isMuted = false
        seekVolume(to: mutedVolume)
    }

    func seekTime(to time: TimeInterval) {
        player.seek(time: time)
    }

    func seekProgress(to progress: CGFloat) {
        player.seek(position: Double(progress))
    }

    func seekVolume(to volume: CGFloat) {
        do {
            try player.setVolume(Float(volume))
        } catch {
            print(error)
        }
    }
    
    func withEngine(_ block: @escaping (AVAudioEngine) -> Void) {
        player.withEngine { [weak self] engine in
            block(engine)
        }
    }
}

extension SFBAudioEnginePlayer {
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

extension SFBAudioEnginePlayer: AudioPlayer.Delegate {
    func audioPlayerEndOfAudio(_ audioPlayer: AudioPlayer) {
        delegate?.playerDidFinishPlaying(self)

        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayerEndOfAudio?(audioPlayer)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, decodingStarted decoder: any PCMDecoding) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, decodingStarted: decoder)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, decodingComplete decoder: any PCMDecoding) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, decodingComplete: decoder)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, encounteredError error: any Error) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, encounteredError: error)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, renderingStarted decoder: any PCMDecoding) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, renderingStarted: decoder)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, renderingComplete decoder: any PCMDecoding) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, renderingComplete: decoder)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, audioWillEndAt hostTime: UInt64) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, audioWillEndAt: hostTime)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, renderingWillStart decoder: any PCMDecoding, at hostTime: UInt64) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, renderingWillStart: decoder, at: hostTime)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, renderingWillComplete decoder: any PCMDecoding, at hostTime: UInt64) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, renderingWillComplete: decoder, at: hostTime)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, decodingCanceled decoder: any PCMDecoding, partiallyRendered: Bool) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayer?(audioPlayer, decodingCanceled: decoder, partiallyRendered: partiallyRendered)
        }
    }

    func audioPlayerNowPlayingChanged(_ audioPlayer: AudioPlayer) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayerNowPlayingChanged?(audioPlayer)
        }
    }

    func audioPlayerPlaybackStateChanged(_ audioPlayer: AudioPlayer) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayerPlaybackStateChanged?(audioPlayer)
        }
    }

    func audioPlayerAVAudioEngineConfigurationChange(_ audioPlayer: AudioPlayer) {
        if let delegate = delegate as? AudioPlayer.Delegate {
            delegate.audioPlayerAVAudioEngineConfigurationChange?(audioPlayer)
        }
    }
}
