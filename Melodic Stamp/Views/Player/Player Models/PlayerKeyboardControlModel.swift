//
//  PlayerKeyboardControlModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

@Observable final class PlayerKeyboardControlModel {
    var previousSongButtonBounceAnimation: Bool = false
    var nextSongButtonBounceAnimation: Bool = false
    var speakerButtonBounceAnimation: Bool = false
    
    var isPressingSpace: Bool = false
    var progressBarExternalOvershootSign: FloatingPointSign?
    
    @discardableResult func handlePlayPause(in player: PlayerModel, phase: KeyPress.Phases, modifiers: EventModifiers = []) -> KeyPress.Result {
        guard player.hasCurrentTrack else { return .ignored }
        
        switch phase {
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
    
    @discardableResult func handleProgressAdjustment(in player: PlayerModel, phase: KeyPress.Phases, modifiers: EventModifiers = [], sign: FloatingPointSign) -> KeyPress.Result {
        switch phase {
        case .down, .repeat:
            guard player.hasCurrentTrack else { return .ignored }
            
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
                progressBarExternalOvershootSign = sign
            }
            
            return .handled
        case .up:
            progressBarExternalOvershootSign = nil
            return .ignored
        default:
            return .ignored
        }
    }
    
    @discardableResult func handleVolumeAdjustment(in player: PlayerModel, phase: KeyPress.Phases, modifiers: EventModifiers = [], sign: FloatingPointSign) -> KeyPress.Result {
        switch phase {
        case .down, .repeat:
            guard player.hasCurrentTrack else { return .ignored }
            
            let hasShift = modifiers.contains(.shift)
            let hasOption = modifiers.contains(.option)
            let multiplier: CGFloat = if hasShift, !hasOption {
                5
            } else if hasOption, !hasShift {
                0.1
            } else { 1 }
            
            let inRange = player.adjustVolume(multiplier: multiplier, sign: sign)
            
            if !inRange {
                progressBarExternalOvershootSign = sign
                
                if sign == .plus {
                    speakerButtonBounceAnimation.toggle()
                }
            }
            
            return .handled
        case .up:
            progressBarExternalOvershootSign = nil
            return .ignored
        default:
            return .ignored
        }
    }
}
