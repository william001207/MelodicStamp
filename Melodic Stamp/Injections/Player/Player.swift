//
//  Player.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import CSFBAudioEngine
import Foundation
import SFSafeSymbols

protocol Player {
    associatedtype OutputDevice: Device
    
    var delegate: (any PlayerDelegate)? { get set }

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

    func withEngine(_ block: @escaping (AVAudioEngine) -> ())
    
    func availableDevices() throws -> [OutputDevice]
    func selectedDevice() throws -> OutputDevice?
    func selectDevice(_ device: OutputDevice) throws
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
    func playerDidFinishPlaying(_ player: some Player)
}

// - Blank Implementation

struct BlankDevice: Device {
    let id = UUID()
    var name: String { "Blank Device" }
    var symbol: SFSymbol { .questionmark }
}

class BlankPlayer: Player {
    typealias OutputDevice = BlankDevice
    
    var delegate: (any PlayerDelegate)?

    var isPlaying: Bool = false
    var isMuted: Bool = false

    var playbackTime: PlaybackTime? = .init(duration: .seconds(60), elapsed: .zero)
    var playbackVolume: CGFloat = 1

    func play(_: PlayableItem) {
        isPlaying = true
    }
    func enqueue(_: PlayableItem) {}

    func play() {
        isPlaying = true
    }
    func pause() {
        isPlaying = false
    }
    func stop() {
        isPlaying = false
    }
    func mute() {
        isMuted = true
    }
    func unmute() {
        isMuted = false
    }

    func seekTime(to time: TimeInterval) {
        playbackTime = .init(duration: .seconds(60), elapsed: time)
    }
    func seekProgress(to progress: CGFloat) {
        playbackTime = .init(duration: .seconds(60), elapsed: progress * Duration.seconds(60).timeInterval)
    }
    func seekVolume(to volume: CGFloat) {
        playbackVolume = volume
    }

    func withEngine(_: @escaping (AVAudioEngine) -> ()) {}
    
    func availableDevices() throws -> [BlankDevice] {
        [.init()]
    }
    func selectedDevice() throws -> BlankDevice? {
        .init()
    }
    func selectDevice(_ device: BlankDevice) throws {}
}
