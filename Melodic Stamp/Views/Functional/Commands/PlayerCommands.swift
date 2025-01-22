//
//  PlayerCommands.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/8.
//

import CAAudioHardware
import SwiftUI

struct PlayerCommands: Commands {
    @FocusedValue(\.player) private var player
    @FocusedValue(\.playerKeyboardControl) private var playerKeyboardControl

    var body: some Commands {
        CommandMenu("Player") {
            Group {
                Button(player?.isPlaying ?? false ? "Pause" : "Play") {
                    player?.togglePlayPause()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(!isPlayable)

                Group {
                    Button("Fast Forward") {
                        playerKeyboardControl?.handleProgressAdjustment(
                            phase: .all, sign: .plus
                        )
                    }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Fast Forward") {
                            playerKeyboardControl?.handleProgressAdjustment(
                                phase: .all, modifiers: .shift, sign: .plus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Fast Forward") {
                            playerKeyboardControl?.handleProgressAdjustment(
                                phase: .all, modifiers: .option, sign: .plus
                            )
                        }
                        .badge("×0.1")
                    }

                    Button("Rewind") {
                        playerKeyboardControl?.handleProgressAdjustment(
                            phase: .all, sign: .minus
                        )
                    }
                    .keyboardShortcut(.leftArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Rewind") {
                            playerKeyboardControl?.handleProgressAdjustment(
                                phase: .all, modifiers: .shift, sign: .minus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Rewind") {
                            playerKeyboardControl?.handleProgressAdjustment(
                                phase: .all, modifiers: .option, sign: .minus
                            )
                        }
                        .badge("×0.1")
                    }
                }
                .disabled(!isPlayable)

                Divider()

                Group {
                    Group {
                        if let player {
                            @Bindable var player = player

                            Toggle("Mute", isOn: $player.isMuted)
                        } else {
                            Button("Mute") {
                                // Do nothing
                            }
                        }
                    }
                    .keyboardShortcut("m", modifiers: [.command, .control])

                    Button("Louder") {
                        playerKeyboardControl?.handleVolumeAdjustment(
                            phase: .all, sign: .plus
                        )
                    }
                    .keyboardShortcut(.upArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Louder") {
                            playerKeyboardControl?.handleVolumeAdjustment(
                                phase: .all, modifiers: .shift, sign: .plus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Louder") {
                            playerKeyboardControl?.handleVolumeAdjustment(
                                phase: .all, modifiers: .option, sign: .plus
                            )
                        }
                        .badge("×0.1")
                    }

                    Button("Quieter") {
                        playerKeyboardControl?.handleVolumeAdjustment(
                            phase: .all, sign: .minus
                        )
                    }
                    .keyboardShortcut(.downArrow, modifiers: .command)
                    .modifierKeyAlternate(.shift) {
                        Button("Quieter") {
                            playerKeyboardControl?.handleVolumeAdjustment(
                                phase: .all, modifiers: .shift, sign: .minus
                            )
                        }
                        .badge("×5")
                    }
                    .modifierKeyAlternate(.option) {
                        Button("Quieter") {
                            playerKeyboardControl?.handleVolumeAdjustment(
                                phase: .all, modifiers: .option, sign: .minus
                            )
                        }
                        .badge("×0.1")
                    }
                }
                .disabled(!isPlayable)

                Divider()

                Group {
                    Button("Next Track") {
                        player?.playNextTrack()
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [.command, .control])
                    .disabled(!hasNextTrack)

                    Button("Previous Track") {
                        player?.playPreviousTrack()
                    }
                    .keyboardShortcut(.leftArrow, modifiers: [.command, .control])
                    .disabled(!hasPreviousTrack)
                }
                .disabled(!hasCurrentTrack)

                if let player {
                    @Bindable var player = player
                    let playbackName = PlaybackModeView.name(of: player.playbackMode)

                    Menu("Playback") {
                        ForEach(PlaybackMode.allCases) { mode in
                            let binding: Binding<Bool> = Binding {
                                player.playbackMode == mode
                            } set: { newValue in
                                guard newValue else { return }
                                player.playbackMode = mode
                            }

                            Toggle(isOn: binding) {
                                PlaybackModeView(mode: mode)
                            }
                        }

                        Divider()

                        Toggle(isOn: $player.playbackLooping) {
                            Image(systemSymbol: .repeat1)

                            Text("Looping")
                        }
                    }
                    .badge(playbackName)
                } else {
                    Button("Playback") {
                        // Do nothing
                    }
                }
            }
            .disabled(!hasPlayer || !hasPlayerKeyboardControl)

            if let player {
                @Bindable var player = player
                let outputDeviceName = OutputDeviceView.name(of: player.selectedOutputDevice)

                Picker("Output Device", selection: $player.selectedOutputDevice) {
                    OutputDeviceList(devices: player.outputDevices, defaultSystemDevice: player.defaultSystemOutputDevice)
                }
                .badge(outputDeviceName)
            }
        }
    }

    private var hasPlayer: Bool { player != nil }

    private var hasPlayerKeyboardControl: Bool { playerKeyboardControl != nil }

    private var isPlayable: Bool { player?.isPlayable ?? false }

    private var hasCurrentTrack: Bool { player?.hasCurrentTrack ?? false }

    private var hasPreviousTrack: Bool { player?.hasPreviousTrack ?? false }

    private var hasNextTrack: Bool { player?.hasNextTrack ?? false }
}
