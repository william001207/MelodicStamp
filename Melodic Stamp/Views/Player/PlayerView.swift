//
//  PlayerView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/22.
//

import CAAudioHardware
import Luminare
import SFSafeSymbols
import SwiftUI

struct PlayerView: View {
    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(PlayerModel.self) private var player
    @Environment(PlayerKeyboardControlModel.self) private var playerKeyboardControl

    var namespace: Namespace.ID

    @State private var isProgressBarActive: Bool = false
    @State private var isVolumeBarActive: Bool = false

    @State private var adjustmentPercentage: CGFloat = .zero
    @State private var shouldUseRemainingDuration: Bool = false

    @State private var playbackTime: PlaybackTime?

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header()

            HStack(alignment: .center, spacing: 24) {
                HStack(alignment: .center, spacing: 12) {
                    leadingControls()
                }

                Divider()

                HStack(alignment: .center, spacing: 8) {
                    progressBar()
                }

                Divider()

                HStack(alignment: .center, spacing: 24) {
                    trailingControls()
                }
            }
            .frame(height: 32)
            .animation(.default, value: isProgressBarActive)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        // Receive playback time update
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            guard newValue == nil else { return }
            playbackTime = nil
        }
    }

    @ViewBuilder private func header() -> some View {
        HStack(alignment: .center, spacing: 12) {
            
            // Expand / shrink
            AliveButton(
                enabledStyle: .tertiary, hoveringStyle: .secondary
            ) {
                windowManager.style = .miniPlayer
            } label: {
                Image(systemSymbol: .arrowUpRightAndArrowDownLeft)
                    .font(.headline)
                    .frame(width: 20)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.expandShrinkButton, in: namespace
            )
            
            Divider()
            
            // Playback mode
            AliveButton(
                enabledStyle: .tertiary, hoveringStyle: .secondary
            ) {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(
                    negate: hasShift)
            } label: {
                Image(systemSymbol: player.playbackMode.systemSymbol)
                    .font(.headline)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 20)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.playbackModeButton, in: namespace
            )

            // Playback looping
            AliveButton(
                enabledStyle: .tertiary, hoveringStyle: .secondary
            ) {
                player.playbackLooping.toggle()
            } label: {
                Image(systemSymbol: .repeat1)
                    .font(.headline)
                    .frame(width: 20, height: 20)
                    .aliveHighlight(player.playbackLooping)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.playbackLoopingButton, in: namespace
            )

            Spacer()

            Group {
                ShrinkableMarqueeScrollView {
                    MusicTitle(item: player.current)
                }
                //                .contentTransition(.numericText())
                .animation(.default, value: player.currentIndex)
                .matchedGeometryEffect(id: PlayerNamespace.title, in: namespace)

                /*
                if let thumbnail = player.current?.metadata.thumbnail {
                    MusicCover(
                        images: [thumbnail], hasPlaceholder: false,
                        cornerRadius: 2
                    )
                }
                */
            }
            .padding(.bottom, 2)

            Spacer()

            // Output device
            if let outputDevice = player.selectedOutputDevice {
                let binding: Binding<AudioDevice> = Binding {
                    outputDevice
                } set: { newValue in
                    player.selectOutputDevice(newValue)
                }

                Picker("", selection: binding) {
                    OutputDeviceList(devices: player.outputDevices)
                }
                .labelsHidden()
                .buttonStyle(.borderless)
                .tint(.secondary)
            }
        }
        .frame(height: 20)
    }

    @ViewBuilder private func leadingControls() -> some View {
        Group {
            // Previous track
            AliveButton {
                player.previousTrack()
                playerKeyboardControl.previousSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .backwardFill)
                    .font(.headline)
            }
            .disabled(!player.hasPreviousTrack)
            .symbolEffect(
                .bounce,
                value: playerKeyboardControl.previousSongButtonBounceAnimation
            )
            .matchedGeometryEffect(
                id: PlayerNamespace.previousSongButton, in: namespace
            )

            // Play / pause
            AliveButton {
                player.isPlaying.toggle()
                playerKeyboardControl.isPressingSpace = false
            } label: {
                player.playPauseImage
                    .font(.title)
                    .contentTransition(.symbolEffect(.replace.upUp))
                    .frame(width: 20)
            }
            .scaleEffect(
                playerKeyboardControl.isPressingSpace ? 0.75 : 1,
                anchor: .center
            )
            .animation(.bouncy, value: playerKeyboardControl.isPressingSpace)
            .matchedGeometryEffect(
                id: PlayerNamespace.playPauseButton, in: namespace
            )

            // Next track
            AliveButton {
                player.nextTrack()
                playerKeyboardControl.nextSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .forwardFill)
                    .font(.headline)
            }
            .disabled(!player.hasNextTrack)
            .symbolEffect(
                .bounce,
                value: playerKeyboardControl.nextSongButtonBounceAnimation
            )
            .matchedGeometryEffect(
                id: PlayerNamespace.nextSongButton, in: namespace
            )
        }
        .disabled(!player.hasCurrentTrack)
    }

    @ViewBuilder private func trailingControls() -> some View {
        ProgressBar(
            value: volumeBinding,
            isActive: $isVolumeBarActive,
            externalOvershootSign: playerKeyboardControl.volumeBarExternalOvershootSign,
            onOvershootOffsetChange: { oldValue, newValue in
                if oldValue <= 0, newValue > 0 {
                    playerKeyboardControl.speakerButtonBounceAnimation.toggle()
                }
            }
        )
        .foregroundStyle(
            isVolumeBarActive
                ? .primary : player.isMuted ? .quaternary : .secondary
        )
        .backgroundStyle(.quinary)
        .frame(width: 72, height: 12)
        .animation(.default.speed(2), value: player.isMuted)
        .matchedGeometryEffect(id: PlayerNamespace.volumeBar, in: namespace)

        // Speaker
        AliveButton(enabledStyle: .secondary) {
            player.isMuted.toggle()
        } label: {
            player.speakerImage
                .font(.headline)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 16)
        }
        .symbolEffect(
            .bounce, value: playerKeyboardControl.speakerButtonBounceAnimation
        )
        .matchedGeometryEffect(id: PlayerNamespace.volumeButton, in: namespace)
    }

    @ViewBuilder private func progressBar() -> some View {
        let time: TimeInterval? = if isProgressBarActive {
            // Use adjustment time
            if shouldUseRemainingDuration {
                (playbackTime?.duration).map {
                    $0.timeInterval * (1 - adjustmentPercentage)
                }
            } else {
                (playbackTime?.duration).map {
                    $0.timeInterval * adjustmentPercentage
                }
            }
        } else {
            // Use track time
            if shouldUseRemainingDuration {
                playbackTime?.remaining
            } else {
                playbackTime?.elapsed
            }
        }

        DurationText(
            duration: time?.duration,
            sign: shouldUseRemainingDuration ? .minus : .plus
        )
        .frame(width: 40)
        .foregroundStyle(.secondary)
        .padding(.bottom, 1)
        .onTapGesture {
            shouldUseRemainingDuration.toggle()
        }
        .matchedGeometryEffect(id: PlayerNamespace.timeText, in: namespace)

        ProgressBar(
            value: progressBinding,
            isActive: $isProgressBarActive,
            isDelegated: true,
            externalOvershootSign: playerKeyboardControl
                .progressBarExternalOvershootSign,
            onPercentageChange: { _, newValue in
                adjustmentPercentage = newValue
            }
        )
        .disabled(!player.hasCurrentTrack)
        .foregroundStyle(isProgressBarActive ? .primary : .secondary)
        .backgroundStyle(.quinary)
        .frame(height: 12)
        .matchedGeometryEffect(id: PlayerNamespace.progressBar, in: namespace)
        .padding(.horizontal, isProgressBarActive ? 0 : 12)

        DurationText(duration: playbackTime?.duration)
            .frame(width: 40)
            .foregroundStyle(.secondary)
            .padding(.bottom, 1)
            .matchedGeometryEffect(
                id: PlayerNamespace.durationText, in: namespace
            )
    }

    private var progressBinding: Binding<CGFloat> {
        Binding {
            playbackTime?.progress ?? .zero
        } set: { newValue in
            player.progress = newValue
        }
    }

    private var volumeBinding: Binding<CGFloat> {
        Binding {
            player.volume
        } set: { newValue in
            player.volume = newValue
        }
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    @Previewable @Namespace var namespace

    PlayerView(namespace: namespace)
}
