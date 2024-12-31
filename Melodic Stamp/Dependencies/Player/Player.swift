//
//  Player.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

protocol Player {
    var isPlaying: Bool { get }
    var isMuted: Bool { get }

    var playbackTime: PlaybackTime? { get }
    var playbackVolume: CGFloat { get }

    func play(_ item: PlayableItem)
    func enqueue(_ item: PlayableItem)

    func play()
    func pause()
    func stop()
    func mute()
    func unmute()

    func setPlaying(_ playing: Bool)
    func togglePlaying()
    func setMuted(_ muted: Bool)
    func toggleMuted()

    func seekTime(to time: TimeInterval)
    func seekProgress(to progress: CGFloat)
    func seekVolume(to volume: CGFloat)
}

extension Player {
    func setPlaying(_ playing: Bool) {
        if playing {
            play()
        } else {
            pause()
        }
    }

    func togglePlaying() {
        setPlaying(!isPlaying)
    }

    func setMuted(_ muted: Bool) {
        if muted {
            mute()
        } else {
            unmute()
        }
    }

    func toggleMuted() {
        setMuted(!isMuted)
    }
}

protocol PlayerDelegate {
    func playerDidFinishPlaying(_ player: Player)
}

struct BlankPlayer: Player {
    var isPlaying: Bool { false }

    var isMuted: Bool { false }

    var playbackTime: PlaybackTime? { nil }

    var playbackVolume: CGFloat { .zero }

    func play(_: PlayableItem) {}

    func enqueue(_: PlayableItem) {}

    func play() {}

    func pause() {}

    func stop() {}

    func mute() {}

    func unmute() {}

    func seekTime(to _: TimeInterval) {}

    func seekProgress(to _: CGFloat) {}

    func seekVolume(to _: CGFloat) {}
}
