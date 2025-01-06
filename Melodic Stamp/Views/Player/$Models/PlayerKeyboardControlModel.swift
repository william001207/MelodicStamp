//
//  PlayerKeyboardControlModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

@Observable final class PlayerKeyboardControlModel {
    var previousSongButtonBounceAnimation: Bool = false
    var nextSongButtonBounceAnimation: Bool = false
    var speakerButtonBounceAnimation: Bool = false

    var isPressingSpace: Bool = false
    var progressBarExternalOvershootSign: OvershootSign = .none
    var volumeBarExternalOvershootSign: OvershootSign = .none

    @discardableResult func handlePlayPause(
        in player: PlayerModel,
        phase: KeyPress.Phases, modifiers: EventModifiers = []
    ) -> KeyPress.Result {
        guard player.hasCurrentTrack else { return .ignored }

        switch phase {
        case .all:
            handlePlayPause(in: player, phase: .down, modifiers: modifiers)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handlePlayPause(in: player, phase: .up, modifiers: modifiers)
            }
            return .handled
        case .down:
            guard !isPressingSpace else { return .ignored }

            player.togglePlayPause()
            isPressingSpace = true
            return .handled
        case .up:
            isPressingSpace = false
            return .handled
        default:
            return .ignored
        }
    }

    @discardableResult func handleProgressAdjustment(
        in player: PlayerModel,
        phase: KeyPress.Phases, modifiers: EventModifiers = [], sign: FloatingPointSign
    ) -> KeyPress.Result {
        switch phase {
        case .all:
            handleProgressAdjustment(in: player, phase: .down, modifiers: modifiers, sign: sign)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleProgressAdjustment(in: player, phase: .up, modifiers: modifiers, sign: sign)
            }
            return .handled
        case .down, .repeat:
            guard player.isPlayable else { return .ignored }

            if modifiers.contains(.command) {
                switch sign {
                case .plus:
                    player.nextTrack()
                    nextSongButtonBounceAnimation.toggle()
                case .minus:
                    player.previousTrack()
                    previousSongButtonBounceAnimation.toggle()
                }

                return .handled
            }

            let hasShift = modifiers.contains(.shift)
            let hasOption = modifiers.contains(.option)
            let multiplier: CGFloat = if hasShift, !hasOption {
                5
            } else if hasOption, !hasShift {
                0.1
            } else { 1 }

            let inRange = player.adjustTime(multiplier: multiplier, sign: sign)

            if !inRange {
                progressBarExternalOvershootSign = .init(sign)
            }

            return .handled
        case .up:
            progressBarExternalOvershootSign = .none
            return .handled
        default:
            return .ignored
        }
    }

    @discardableResult func handleVolumeAdjustment(
        in player: PlayerModel,
        phase: KeyPress.Phases, modifiers: EventModifiers = [], sign: FloatingPointSign
    ) -> KeyPress.Result {
        switch phase {
        case .all:
            handleVolumeAdjustment(in: player, phase: .down, modifiers: modifiers, sign: sign)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleVolumeAdjustment(in: player, phase: .up, modifiers: modifiers, sign: sign)
            }
            return .ignored
        case .down, .repeat:
            guard player.isPlayable else { return .ignored }

            let hasShift = modifiers.contains(.shift)
            let hasOption = modifiers.contains(.option)
            let multiplier: CGFloat = if hasShift, !hasOption {
                5
            } else if hasOption, !hasShift {
                0.1
            } else { 1 }

            let inRange = player.adjustVolume(multiplier: multiplier, sign: sign)

            if !inRange {
                volumeBarExternalOvershootSign = .init(sign)
                speakerButtonBounceAnimation.toggle()
            }

            return .handled
        case .up:
            volumeBarExternalOvershootSign = .none
            return .handled
        default:
            return .ignored
        }
    }
}
