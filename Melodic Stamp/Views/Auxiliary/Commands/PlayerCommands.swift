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
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(player?.hasCurrentTrack != true)

                Group {
                    Button("Fast Forward") {
                        guard let player else { return }
                        playerKeyboardControl?.handleProgressAdjustment(
                            in: player, phase: .down, sign: .plus
                        )
                    }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Fast Forward") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .shift,
                                sign: .plus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Fast Forward") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .option,
                                sign: .plus
                            )
                        }
                        .badge("×0.1")
                    }

                    Button("Rewind") {
                        guard let player else { return }
                        playerKeyboardControl?.handleProgressAdjustment(
                            in: player, phase: .down, sign: .minus
                        )
                    }
                    .keyboardShortcut(.leftArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Rewind") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .shift,
                                sign: .minus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Rewind") {
                            guard let player else { return }
                            playerKeyboardControl?.handleProgressAdjustment(
                                in: player, phase: .down, modifiers: .option,
                                sign: .minus
                            )
                        }
                        .badge("×0.1")
                    }
                }
                .disabled(player?.hasCurrentTrack != true)

                Divider()

                Button(player?.isMuted ?? false ? "Unmute" : "Mute") {
                    player?.isMuted.toggle()
                }
                .keyboardShortcut("m", modifiers: [.command, .control])

                Button("Louder") {
                    guard let player else { return }
                    playerKeyboardControl?.handleVolumeAdjustment(
                        in: player, phase: .down, sign: .plus
                    )
                }
                .keyboardShortcut(.upArrow, modifiers: .command)
                .modifierKeyAlternate(.shift) {
                    Button("Louder") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .shift,
                            sign: .plus
                        )
                    }
                    .badge("×5")
                }
                .modifierKeyAlternate(.option) {
                    Button("Louder") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .option,
                            sign: .plus
                        )
                    }
                    .badge("×0.1")
                }

                Button("Quieter") {
                    guard let player else { return }
                    playerKeyboardControl?.handleVolumeAdjustment(
                        in: player, phase: .down, sign: .minus
                    )
                }
                .keyboardShortcut(.downArrow, modifiers: .command)
                .modifierKeyAlternate(.shift) {
                    Button("Quieter") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .shift,
                            sign: .minus
                        )
                    }
                    .badge("×5")
                }
                .modifierKeyAlternate(.option) {
                    Button("Quieter") {
                        guard let player else { return }
                        playerKeyboardControl?.handleVolumeAdjustment(
                            in: player, phase: .down, modifiers: .option,
                            sign: .minus
                        )
                    }
                    .badge("×0.1")
                }

                Divider()

                Button("Next Song") {
                    player?.nextTrack()
                }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .control])
                .disabled(player?.hasNextTrack != true)

                Button("Previous Song") {
                    player?.previousTrack()
                }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .control])
                .disabled(player?.hasPreviousTrack != true)

                if let player {
                    @Bindable var player = player
                    let playbackName: String =
                        switch player.playbackMode {
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
}
