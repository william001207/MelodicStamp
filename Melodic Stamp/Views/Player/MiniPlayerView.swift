//
//  MiniPlayerView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import CAAudioHardware
import Luminare
import SFSafeSymbols
import SwiftUI

struct MiniPlayerView: View {
    enum ActiveControl: Equatable {
        case progress
        case volume

        var id: PlayerNamespace {
            switch self {
            case .progress: .progressBar
            case .volume: .volumeBar
            }
        }
    }

    enum HeaderControl: Equatable {
        case title
        case lyrics

        var hasThumbnail: Bool {
            switch self {
            case .title: true
            case .lyrics: false
            }
        }
    }

    @FocusState private var isFocused: Bool

    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(FileManagerModel.self) private var fileManager
    @Environment(PlayerModel.self) private var player
    @Environment(PlayerKeyboardControlModel.self) private var playerKeyboardControl

    var namespace: Namespace.ID

    @State private var lyrics: LyricsModel = .init()
    @State private var alwaysOnTop: AlwaysOnTopModel = .init()

    @State private var activeControl: ActiveControl = .progress
    @State private var headerControl: HeaderControl = .title

    @State private var isTitleHovering: Bool = false
    @State private var isProgressBarHovering: Bool = false
    @State private var isProgressBarActive: Bool = false

    @State private var adjustmentPercentage: CGFloat = .zero
    @State private var shouldUseRemainingDuration: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            header()
                .padding(.horizontal, 4)
                .onHover { hover in
                    withAnimation(.default.speed(2)) {
                        isTitleHovering = hover
                    }
                }

            HStack(alignment: .center, spacing: 12) {
                leadingControls()
                    .transition(.blurReplace)

                progressBar()

                trailingControls()
                    .transition(.blurReplace)
            }
            .frame(height: 16)
            .animation(.default, value: isProgressBarHovering)
            .animation(.default, value: isProgressBarActive)
            .animation(.default, value: activeControl)
            .animation(.default, value: headerControl)
        }
        .padding(12)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        // Allow fully customization to the corresponding window
        .background(MakeAlwaysOnTop(
            isAlwaysOnTop: $alwaysOnTop.isAlwaysOnTop, titleVisibility: $alwaysOnTop.titleVisibility
        ))

        // Read lyrics
        // Don't extract this logic or modify the tasks!
        .onAppear {
            guard let track = player.track else { return }

            Task {
                let raw = await track.metadata.poll(for: \.lyrics).current
                await lyrics.read(raw)
            }
        }
        .onChange(of: player.track) { _, newValue in
            guard let newValue else { return }
            lyrics.clear(newValue.url)

            Task {
                let raw = await newValue.metadata.poll(for: \.lyrics).current
                await lyrics.read(raw)
            }
        }

        // Regain progress control on new track
        .onChange(of: player.currentIndex) { _, newValue in
            guard newValue != nil else { return }
            activeControl = .progress
        }

        // Handle space down/up -> toggle play pause
        .onKeyPress(keys: [.space], phases: .all) { key in
            playerKeyboardControl.handlePlayPause(
                in: player, phase: key.phase, modifiers: key.modifiers
            )
        }

        // Handle left arrow/right arrow down/repeat/up -> adjust progress & volume
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

            return switch activeControl {
            case .progress:
                playerKeyboardControl.handleProgressAdjustment(
                    in: player, phase: key.phase, modifiers: key.modifiers,
                    sign: sign
                )
            case .volume:
                playerKeyboardControl.handleVolumeAdjustment(
                    in: player, phase: key.phase, modifiers: key.modifiers,
                    sign: sign
                )
            }
        }

        // Handle escape -> regain progress control
        .onKeyPress(.escape) {
            guard activeControl == .volume else { return .ignored }

            activeControl = .progress
            return .handled
        }

        // Handle m -> toggle mute
        .onKeyPress(keys: ["m"], phases: .down) { _ in
            player.isMuted.toggle()
            return .handled
        }
    }

    private var isProgressBarExpanded: Bool {
        guard player.hasCurrentTrack || activeControl == .volume else {
            return false
        }
        return isProgressBarHovering || isProgressBarActive
    }

    @ViewBuilder private func header() -> some View {
        @Bindable var player = player

        HStack(alignment: .center, spacing: 12) {
            if isTitleHovering {
                // Playlist
                Menu {
                    Button("Open in Playlist") {
                        fileManager.emitOpen(style: .inCurrentPlaylist)
                    }

                    Button("Add to Playlist") {
                        fileManager.emitAdd(style: .toCurrentPlaylist)
                    }

                    Divider()

                    playlistMenu()
                } label: {
                    Image(systemSymbol: .listTriangle)
                }
                .buttonStyle(.borderless)
                .tint(.secondary)
            }

            // Playback mode
            AliveButton(
                enabledStyle: .tertiary, hoveringStyle: .secondary
            ) {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(negate: hasShift)
            } label: {
                Image(systemSymbol: player.playbackMode.systemSymbol)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 16)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.playbackModeButton, in: namespace
            )
            .contextMenu {
                PlaybackModePicker(selection: $player.playbackMode)
            }

            // Playback looping
            AliveButton(
                enabledStyle: .tertiary, hoveringStyle: .secondary
            ) {
                player.playbackLooping.toggle()
            } label: {
                Image(systemSymbol: .repeat1)
                    .frame(width: 16, height: 16)
                    .aliveHighlight(player.playbackLooping)
            }
            .matchedGeometryEffect(
                id: PlayerNamespace.playbackLoopingButton, in: namespace
            )

            AliveButton {
                headerControl = switch headerControl {
                case .title:
                    .lyrics
                case .lyrics:
                    .title
                }
            } label: {
                ShrinkableMarqueeScrollView {
                    switch headerControl {
                    case .title:
                        MusicTitle(item: player.track)
                    case .lyrics:
                        ComposedLyricsView()
                            .environment(lyrics)
                    }
                }
                .animation(.default, value: player.currentIndex)
                .matchedGeometryEffect(id: PlayerNamespace.title, in: namespace)
                .padding(.bottom, 2)
            }

            if headerControl.hasThumbnail, let thumbnail = player.track?.metadata.thumbnail {
                MusicCover(images: [thumbnail], hasPlaceholder: false, cornerRadius: 2)
                    .padding(.bottom, 2)
            }

            // Pin / unpin
            if isTitleHovering || alwaysOnTop.isAlwaysOnTop {
                AliveButton(
                    enabledStyle: .tertiary, hoveringStyle: .secondary
                ) {
                    alwaysOnTop.isAlwaysOnTop.toggle()
                } label: {
                    Image(systemSymbol: .pinFill)
                        .frame(width: 16, height: 16)
                        .contentTransition(.symbolEffect(.replace))
                        .aliveHighlight(alwaysOnTop.isAlwaysOnTop)
                }
                .transition(.blurReplace)
            }

            if isTitleHovering {
                // Expand / shrink
                AliveButton(
                    enabledStyle: .tertiary, hoveringStyle: .secondary
                ) {
                    alwaysOnTop.giveUp()
                    windowManager.style = .main
                } label: {
                    Image(systemSymbol: .arrowUpLeftAndArrowDownRight)
                }
                .matchedGeometryEffect(
                    id: PlayerNamespace.expandShrinkButton, in: namespace
                )
                .transition(.blurReplace)
            }
        }
        .frame(height: 16)
    }

    @ViewBuilder private func leadingControls() -> some View {
        if !isProgressBarExpanded {
            Group {
                // Previous track
                AliveButton {
                    player.previousTrack()
                    playerKeyboardControl.previousSongButtonBounceAnimation
                        .toggle()
                } label: {
                    Image(systemSymbol: .backwardFill)
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
                        .font(.title2)
                        .contentTransition(.symbolEffect(.replace.upUp))
                        .frame(width: 16)
                }
                .scaleEffect(
                    playerKeyboardControl.isPressingSpace ? 0.75 : 1,
                    anchor: .center
                )
                .animation(
                    .bouncy, value: playerKeyboardControl.isPressingSpace
                )
                .matchedGeometryEffect(
                    id: PlayerNamespace.playPauseButton, in: namespace
                )

                // Next track
                AliveButton {
                    player.nextTrack()
                    playerKeyboardControl.nextSongButtonBounceAnimation.toggle()
                } label: {
                    Image(systemSymbol: .forwardFill)
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
    }

    @ViewBuilder private func trailingControls() -> some View {
        @Bindable var player = player
        let isVolumeControlActive = activeControl == .volume

        if isVolumeControlActive {
            if isProgressBarExpanded {
                // Preserves spacing
                Spacer()
                    .frame(width: 0)
            } else {
                // Output device
                Menu {
                    OutputDevicePicker(
                        devices: player.outputDevices,
                        selection: $player.selectedOutputDevice
                    )
                    .onAppear {
                        player.updateOutputDevices()
                    }
                } label: {
                    Image(systemSymbol: .airplayaudio)
                }
                .buttonStyle(.borderless)
                .tint(.secondary)
            }
        }

        if isVolumeControlActive || !isProgressBarExpanded {
            // Speaker
            AliveButton(enabledStyle: .secondary) {
                activeControl = switch activeControl {
                case .progress:
                    .volume
                case .volume:
                    .progress
                }
            } label: {
                player.speakerImage
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 20, height: 16)
            }
            .symbolEffect(.bounce, value: activeControl)
            .symbolEffect(
                .bounce,
                value: playerKeyboardControl.speakerButtonBounceAnimation
            )
            .matchedGeometryEffect(
                id: PlayerNamespace.volumeButton, in: namespace
            )
            .contextMenu {
                if player.isPlayable {
                    Toggle("Mute", isOn: $player.isMuted)
                }
            }
        }
    }

    @ViewBuilder private func progressBar() -> some View {
        @Bindable var player = player
        let isProgressControlActive = activeControl == .progress
        let isVolumeControlActive = activeControl == .volume

        HStack(alignment: .center, spacing: 8) {
            Group {
                if isProgressControlActive {
                    let time: TimeInterval? = if isProgressBarActive {
                        // Use adjustment time
                        if shouldUseRemainingDuration {
                            (player.playbackTime?.duration).map {
                                TimeInterval($0) * (1 - adjustmentPercentage)
                            }
                        } else {
                            (player.playbackTime?.duration).map {
                                TimeInterval($0) * adjustmentPercentage
                            }
                        }
                    } else {
                        // Use track time
                        if shouldUseRemainingDuration {
                            player.playbackTime?.remaining
                        } else {
                            player.playbackTime?.elapsed
                        }
                    }

                    DurationText(
                        duration: time.flatMap(Duration.init),
                        sign: shouldUseRemainingDuration ? .minus : .plus
                    )
                    .frame(width: 40)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 1)
                    .onTapGesture {
                        shouldUseRemainingDuration.toggle()
                    }
                }
            }
            .transition(.blurReplace)
            .matchedGeometryEffect(id: PlayerNamespace.timeText, in: namespace)

            Group {
                let value: Binding<CGFloat> =
                    switch activeControl {
                    case .progress:
                        player.isPlayable ? $player.progress : .constant(0)
                    case .volume:
                        $player.volume
                    }

                ProgressBar(
                    value: value,
                    isActive: $isProgressBarActive,
                    isDelegated: isProgressControlActive,
                    externalOvershootSign: isProgressControlActive
                        ? playerKeyboardControl.progressBarExternalOvershootSign
                        : playerKeyboardControl.volumeBarExternalOvershootSign
                ) { _, newValue in
                    adjustmentPercentage = newValue
                } onOvershootOffsetChange: { oldValue, newValue in
                    if isVolumeControlActive, oldValue <= 0, newValue > 0 {
                        playerKeyboardControl.speakerButtonBounceAnimation.toggle()
                    }
                }
                .disabled(!player.isPlayable)
                .foregroundStyle(
                    isProgressBarActive
                        ? .primary
                        : isVolumeControlActive && player.isMuted
                        ? .quaternary : .secondary
                )
                .backgroundStyle(.quinary)
            }
            .padding(
                .horizontal,
                !isProgressBarHovering || isProgressBarActive ? 0 : 12
            )
            .onHover { hover in
                guard player.isPlayable, hover else { return }

                isProgressBarHovering = true
            }
            .animation(.default.speed(2), value: player.isMuted)
            .matchedGeometryEffect(id: activeControl.id, in: namespace)

            Group {
                if isProgressControlActive {
                    DurationText(duration: player.playbackTime?.duration)
                        .frame(width: 40)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 1)
                }
            }
            .transition(.blurReplace)
            .matchedGeometryEffect(
                id: PlayerNamespace.durationText, in: namespace
            )
        }
        .frame(height: 12)
        .onHover { hover in
            guard !hover else { return }

            isProgressBarHovering = false
        }
    }

    @ViewBuilder private func playlistMenu() -> some View {
        let selection: Binding<Track?> = Binding {
            player.track
        } set: { newValue in
            if let newValue {
                player.play(track: newValue)
            } else {
                player.stop()
            }
        }

        Menu {
            ForEach(player.playlist) { item in
                let binding: Binding<Bool> = Binding {
                    selection.wrappedValue == item
                } set: { newValue in
                    guard newValue else { return }
                    selection.wrappedValue = item
                }

                Toggle(isOn: binding) {
                    if let thumbnail = item.metadata.menuThumbnail {
                        Image(nsImage: thumbnail)
                    }

                    let title = MusicTitle.stringifiedTitle(mode: .title, for: item)
                    Text(title)

                    let subtitle = MusicTitle.stringifiedTitle(mode: .artists, for: item)
                    Text(subtitle)
                }
            }
        } label: {
            if let current = selection.wrappedValue {
                let title = MusicTitle.stringifiedTitle(for: current)
                Text("Playing \(title)")
            } else {
                Text("Playlist")
            }
        }
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    @Previewable @Namespace var namespace

    MiniPlayerView(namespace: namespace)
}
