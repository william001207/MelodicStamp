//
//  Player.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/22.
//

import SFSafeSymbols
import SwiftUI

struct Player: View {
    @Environment(WindowManagerModel.self) var windowManager
    @Environment(PlayerModel.self) var player
    @Environment(PlayerKeyboardControlModel.self) var playerKeyboardControl

    var namespace: Namespace.ID

    @State private var isProgressBarActive: Bool = false
    @State private var isVolumeBarActive: Bool = false

    @State private var adjustmentPercentage: CGFloat = .zero
    @State private var shouldUseRemainingDuration: Bool = false
    
    @State var progress: CGFloat = .zero
    @State var duration: Duration = .zero
    @State var timeElapsed: TimeInterval = .zero
    @State var timeRemaining: TimeInterval = .zero

    @State private var id: UUID = .init()

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header()

//            TimelineView(.animation) { _ in
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
//            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .onReceive(player.playbackTime) { playbackTime in
            
            if let progress = playbackTime.progress {
                self.progress = progress
            }
            
            if let current = playbackTime.current {
                self.timeElapsed = current
            }
            
            if let remaining = playbackTime.remaining {
                self.timeRemaining = -remaining
            }
            
            if let current = playbackTime.current, let remaining = playbackTime.remaining {
                duration =  {playbackTime.total.map { .seconds($0) } ?? .zero }()
            }
        }
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
                id: PlayerNamespace.playbackModeButton, in: namespace
            )

            Spacer()

            Group {
                if let thumbnail = player.current?.metadata.thumbnail {
                    MusicCover(
                        images: [thumbnail], hasPlaceholder: false,
                        cornerRadius: 2
                    )
                }

                ShrinkableMarqueeScrollView {
                    MusicTitle(item: player.current)
                }
//                .contentTransition(.numericText())
//                .animation(.default, value: player.currentIndex)
                .matchedGeometryEffect(id: PlayerNamespace.title, in: namespace)
            }
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
                id: PlayerNamespace.expandShrinkButton, in: namespace
            )
        }
        .frame(height: 20)
    }

    @ViewBuilder private func leadingControls() -> some View {
        Group {
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
                id: PlayerNamespace.playPauseButton, in: namespace
            )

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
        @Bindable var player = player

        ProgressBar(
            value: $player.volume,
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

        AliveButton(enabledStyle: .init(.secondary)) {
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
        @Bindable var player = player

        let time: TimeInterval =
            if isProgressBarActive {
                // Use adjustment time
                if shouldUseRemainingDuration {
                    duration.toTimeInterval()
                        * (1 - adjustmentPercentage)
                } else {
                    player.duration.toTimeInterval() * adjustmentPercentage
                }
            } else {
                // Use track time
                if shouldUseRemainingDuration {
                    timeRemaining
                } else {
                    timeElapsed
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
            value:  Binding(
                get: { self.progress }, // Get the current progress
                set: { newValue in
                    // Use seek to update the progress within valid bounds
                    player.seek(position: max(0, min(1, newValue)))
                }
            ),
            isActive: $isProgressBarActive,
            isDelegated: true,
            externalOvershootSign: playerKeyboardControl
                .progressBarExternalOvershootSign,
            onPercentageChange: { _, newValue in
                adjustmentPercentage = newValue
            }
        )
        .foregroundStyle(isProgressBarActive ? .primary : .secondary)
        .backgroundStyle(.quinary)
        .frame(height: 12)
        .matchedGeometryEffect(id: PlayerNamespace.progressBar, in: namespace)
        .padding(.horizontal, isProgressBarActive ? 0 : 12)
        
//        Slider(
//            value: Binding(
//                get: { self.progress }, // Get the current progress
//                set: { newValue in
//                    // Use seek to update the progress within valid bounds
//                    player.seek(position: max(0, min(1, newValue)))
//                }
//            ),
//            in: 0...1, // Adjust the range based on your progress scale
//            onEditingChanged: { isEditing in
//                isProgressBarActive = isEditing
//            }
//        )
//        .foregroundColor(isProgressBarActive ? .primary : .secondary)
//        .background(Color.gray) // Replace with your preferred background color
//        .frame(height: 12)
//        .matchedGeometryEffect(id: PlayerNamespace.progressBar, in: namespace)
//        .padding(.horizontal, isProgressBarActive ? 0 : 12)
//        .onChange(of: player.progress) { _, newValue in
//            adjustmentPercentage = newValue
//        }

        DurationText(duration: player.duration)
            .frame(width: 40)
            .foregroundStyle(.secondary)
            .matchedGeometryEffect(
                id: PlayerNamespace.durationText, in: namespace
            )
    }
}
