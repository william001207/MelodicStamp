//
//  PlayerCommands.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

struct PlayerCommands: Commands {
    @FocusedValue(\.player) private var player
    @FocusedValue(\.playerKeyboardControl) private var playerKeyboardControl

    var body: some Commands {
        CommandMenu("Player") {
            let hasPlayer = player != nil
            let hasPlayerKeyboardControl = playerKeyboardControl != nil

            Group {
                Button(player?.isPlaying ?? false ? "Pause" : "Play") {
                    player?.togglePlayPause()
                }
                .disabled(player?.hasCurrentTrack != true)

                Group {
                    if hasShift && !hasOption {
                        Button("Fast Forward") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .shift,
                                sign: .plus)
                        }
                        .badge("×5")
                        
                        Button("Rewind") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .shift,
                                sign: .minus)
                        }
                        .badge("×5")
                    } else if hasOption && !hasShift {
                        Button("Fast Forward") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .option,
                                sign: .plus)
                        }
                        .badge("×0.1")
                        
                        Button("Rewind") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .option,
                                sign: .minus)
                        }
                        .badge("×0.1")
                    } else {
                        Button("Fast Forward") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, sign: .plus)
                        }
                        
                        Button("Rewind") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, sign: .minus)
                        }
                    }
                }
                .disabled(player?.hasCurrentTrack != true)

                Divider()

                Button(player?.isMuted ?? false ? "Unmute" : "Mute") {
                    player?.isMuted.toggle()
                }

                if hasShift && !hasOption {
                    Button("Louder") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .shift,
                            sign: .plus)
                    }
                    .badge("×5")

                    Button("Quieter") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .shift,
                            sign: .minus)
                    }
                    .badge("×5")
                } else if hasOption && !hasShift {
                    Button("Louder") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .option,
                            sign: .plus)
                    }
                    .badge("×0.1")

                    Button("Quieter") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .option,
                            sign: .minus)
                    }
                    .badge("×0.1")
                } else {
                    Button("Louder") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, sign: .plus)
                    }

                    Button("Quieter") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, sign: .minus)
                    }
                }

                Divider()

                Button("Next Song") {
                    player?.nextTrack()
                }
                .disabled(player?.hasNextTrack != true)

                Button("Previous Song") {
                    player?.previousTrack()
                }
                .disabled(player?.hasPreviousTrack != true)

                if let player {
                    @Bindable var player = player
                    let playbackName: String = switch player.playbackMode {
                    case .single:
                            .init(localized: "Single Loop")
                    case .sequential:
                            .init(localized: "Sequential")
                    case .loop:
                            .init(localized: "Sequential Loop")
                    case .shuffle:
                            .init(localized: "Shuffle")
                    }
                    
                    Picker("Playback", selection: $player.playbackMode) {
                        ForEach(PlaybackMode.allCases) { mode in
                            PlaybackModeView(mode: mode)
                        }
                    }
                    .badge(playbackName)
                }
            }
            .disabled(!hasPlayer || !hasPlayerKeyboardControl)
        }
    }
    
    private var hasShift: Bool {
        NSEvent.modifierFlags.contains(.shift)
    }
    
    private var hasOption: Bool {
        NSEvent.modifierFlags.contains(.option)
    }
}
