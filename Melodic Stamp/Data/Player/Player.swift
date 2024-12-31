//
//  Player.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

protocol Player {
    var isPlaying: Bool { get }
    var isMuted: Bool { get }
    
    var playbackTime: PlaybackTime? { get }
    var playbackVolume: CGFloat { get }

    mutating func play(_ item: PlayableItem)
    mutating func enqueue(_ item: PlayableItem)
    
    mutating func play()
    mutating func pause()
    mutating func stop()
    mutating func mute()
    mutating func unmute()
    
    mutating func setPlaying(_ playing: Bool)
    mutating func togglePlaying()
    mutating func setMuted(_ muted: Bool)
    mutating func toggleMuted()

    mutating func seekTime(to time: TimeInterval)
    mutating func seekProgress(to progress: CGFloat)
    mutating func seekVolume(to volume: CGFloat)
}

extension Player {
    mutating func setPlaying(_ playing: Bool) {
        if playing {
            pause()
        } else {
            play()
        }
    }
    
    mutating func togglePlaying() {
        setPlaying(!isPlaying)
    }
    
    mutating func setMuted(_ muted: Bool) {
        if muted {
            mute()
        } else {
            unmute()
        }
    }
    
    mutating func toggleMuted() {
        setMuted(!isMuted)
    }
}
