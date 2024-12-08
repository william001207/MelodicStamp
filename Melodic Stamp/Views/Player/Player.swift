//
//  Player.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/22.
//

import SFSafeSymbols
import SwiftUI

struct Player: View {
    @Bindable var windowManager: WindowManagerModel
    @Bindable var player: PlayerModel
    @Bindable var playerKeyboardControl: PlayerKeyboardControlModel

    var namespace: Namespace.ID

    @State private var isProgressBarActive: Bool = false
    @State private var isVolumeBarActive: Bool = false

    @State private var adjustmentPercentage: CGFloat = .zero
    @State private var shouldUseRemainingDuration: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header()

            TimelineView(.animation) { _ in
                HStack(alignment: .center, spacing: 24) {
                    HStack(alignment: .center, spacing: 12) {
                        leadingControls()
                    }

                    Divider()

                    HStack(alignment: .center, spacing: 12) {
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
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func header() -> some View {
        HStack(alignment: .center, spacing: 12) {
            AliveButton(
                enabledStyle: .init(.tertiary), hoveringStyle: .init(.secondary)
            ) {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(
                    negate: hasShift)
            } label: {
                player.playbackMode.image
                    .font(.headline)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 20)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.playbackModeButton, in: namespace)

            Spacer()

            ShrinkableMarqueeScrollView {
                MusicTitle(item: player.current)
            }
            .contentTransition(.numericText())
            .animation(.default, value: player.currentIndex)
            .padding(.bottom, 2)

            Spacer()

            AliveButton(
                enabledStyle: .init(.tertiary), hoveringStyle: .init(.secondary)
            ) {
                windowManager.style = .miniPlayer
            } label: {
                Image(systemSymbol: .arrowDownRightAndArrowUpLeft)
                    .font(.headline)
                    .frame(width: 20)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.expandShrinkButton, in: namespace)
        }
    }

    @ViewBuilder private func leadingControls() -> some View {
        Group {
            AliveButton(enabledStyle: .init(.secondary)) {
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
                id: PlayerNamespace.previousSongButton, in: namespace)

            AliveButton {
                player.togglePlayPause()
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
                id: PlayerNamespace.playPauseButton, in: namespace)

            AliveButton(enabledStyle: .init(.secondary)) {
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
                id: PlayerNamespace.nextSongButton, in: namespace)
        }
        .disabled(!player.hasCurrentTrack)
    }

    @ViewBuilder private func trailingControls() -> some View {
        ProgressBar(
            value: $player.volume,
            isActive: $isVolumeBarActive,
            isDelegated: true
        ) { _, newValue in
            adjustmentPercentage = newValue
        } onOvershootOffsetChange: { oldValue, newValue in
            if oldValue <= 0, newValue > 0 {
                playerKeyboardControl.speakerButtonBounceAnimation.toggle()
            }
        }
        .foregroundStyle(
            isVolumeBarActive
                ? .primary : player.isMuted ? .quaternary : .secondary
        )
        .backgroundStyle(.quinary)
        .frame(width: 72, height: 12)
        .animation(.default.speed(2), value: player.isMuted)
        .matchedGeometryEffect(id: PlayerNamespace.volumeBar, in: namespace)

        AliveButton {
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
        let time: TimeInterval =
            if isProgressBarActive {
                // use adjustment time
                if shouldUseRemainingDuration {
                    player.duration.toTimeInterval()
                        * (1 - adjustmentPercentage)
                } else {
                    player.duration.toTimeInterval() * adjustmentPercentage
                }
            } else {
                // use track time
                if shouldUseRemainingDuration {
                    player.timeRemaining
                } else {
                    player.timeElapsed
                }
            }

        DurationText(
            duration: .seconds(time),
            sign: shouldUseRemainingDuration ? .minus : .plus
        )
        .frame(width: 40)
        .foregroundStyle(.secondary)
        .onTapGesture {
            shouldUseRemainingDuration.toggle()
        }
        .matchedGeometryEffect(id: PlayerNamespace.timeText, in: namespace)

        ProgressBar(
            value: $player.progress,
            isActive: $isProgressBarActive,
            externalOvershootSign: playerKeyboardControl
                .volumeBarExternalOvershootSign
        )
        .foregroundStyle(isProgressBarActive ? .primary : .secondary)
        .backgroundStyle(.quinary)
        .frame(height: 12)
        .matchedGeometryEffect(id: PlayerNamespace.progressBar, in: namespace)
        .padding(.horizontal, isProgressBarActive ? 0 : 12)

        DurationText(duration: player.duration)
            .frame(width: 40)
            .foregroundStyle(.secondary)
            .matchedGeometryEffect(
                id: PlayerNamespace.durationText, in: namespace)
    }
}
