//
//  PlaylistView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import Luminare
import SFSafeSymbols
import SwiftUI

struct PlaylistView: View {
    // MARK: - Environments

    @Environment(KeyboardControlModel.self) private var keyboardControl
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    @Namespace private var coordinateSpace

    // MARK: - Fields

    var namespace: Namespace.ID

    @State private var scrollOffset: CGFloat = .zero
    @State private var containerSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var bounceAnimationTriggers: Set<Track> = []

    // MARK: - Body

    var body: some View {
        @Bindable var player = player

        // MARK: List

        List(selection: $player.selectedTracks) {
            Group {
                // MARK: Controls Placeholder

                // This is much more stable than `.contentMargins()`
                Spacer()
                    .frame(height: minHeight)

                if player.playlist.mode.isCanonical {
                    // MARK: Metadata

                    PlaylistMetadataView(
                        playlist: player.playlist,
                        segments: $player.playlistSegments
                    )
                    .frame(height: metadataHeight)
                    .padding(.horizontal)
                }
            }
            .listRowSeparator(.hidden)
            .selectionDisabled()
            .contentOffset($scrollOffset, in: coordinateSpace)

            // MARK: Tracks

            ForEach(player.playlist.tracks) { track in
                itemView(for: track)
                    .id(track)
                    .draggable(track) {
                        TrackPreview(track: track)
                    }
                    .bounceAnimation(bounceAnimationTriggers.contains(track), scale: .init(width: 1.01, height: 1.01))
            }
            .onMove { indices, destination in
                withAnimation {
                    player.moveTrack(fromOffsets: indices, toOffset: destination)
                }
            }
            .transition(.slide)
        }
        .scrollClipDisabled()
        .scrollContentBackground(.hidden)
        .coordinateSpace(name: coordinateSpace)
        .onScrollGeometryChange(for: CGSize.self) { proxy in
            proxy.containerSize
        } action: { _, newValue in
            containerSize = newValue
        }
        .onScrollGeometryChange(for: CGSize.self) { proxy in
            proxy.contentSize
        } action: { _, newValue in
            contentSize = newValue
        }
        .overlay(alignment: .top) {
            // MARK: Controls

            HStack(spacing: 0) {
                Group {
                    LuminareSection(hasPadding: false) {
                        leadingActions()
                            .frame(height: minHeight)
                    }

                    Spacer()

                    LuminareSection(hasPadding: false) {
                        trailingActions()
                            .frame(height: minHeight)
                    }
                }
                .luminareBordered(false)
                .luminareButtonMaterial(.thin)
                .luminareSectionMasked(true)
                .luminareSectionMaxWidth(nil)
                .shadow(color: .black.opacity(0.1), radius: 15)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .opacity(controlsOpacity)
            .blur(radius: lerp(2.5, 0, factor: controlsOpacity))
            .animation(animationFast, value: controlsOpacity)
            .allowsHitTesting(controlsOpacity >= 0.1)
        }
        .animation(animationFast, value: player.playlist.mode)
        .animation(animationFast, value: player.playlist.tracks)
        .animation(animationFast, value: player.playlist.segments)
        .animation(animationFast, value: player.selectedTracks)

        // MARK: Keyboard Handlers

        // Handle [escape] -> clear selection
        .onKeyPress(.escape) {
            if handleEscape() {
                .handled
            } else {
                .ignored
            }
        }

        // Handle [􁂒] -> remove selection
        .onKeyPress(.deleteForward) {
            if handleRemove(player.selectedTracks.map(\.url)) {
                .handled
            } else {
                .ignored
            }
        }

        // Handle [⏎] -> play
        .onKeyPress(.return) {
            if player.selectedTracks.count == 1, let track = player.selectedTracks.first {
                player.play(track.url)
                return .handled
            } else {
                return .ignored
            }
        }

        // Handle [space] -> toggle play / pause
        .onKeyPress(keys: [.space], phases: .all) { key in
            keyboardControl.handlePlayPause(
                phase: key.phase, modifiers: key.modifiers
            )
        }

        // Handle [← / →] -> adjust progress
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

            return keyboardControl.handleProgressAdjustment(
                phase: key.phase, modifiers: key.modifiers, sign: sign
            )
        }

        // Handle [↑ / ↓] -> adjust volume
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

            return keyboardControl.handleVolumeAdjustment(
                phase: key.phase, modifiers: key.modifiers, sign: sign
            )
        }

        // Handle [m] -> toggle muted
        .onKeyPress(keys: ["m"], phases: .down) { _ in
            player.isMuted.toggle()
            return .handled
        }
    }

    private var canEscape: Bool {
        metadataEditor.hasMetadata
    }

    private var canRemove: Bool {
        !player.playlist.isEmpty
    }

    private var metadataHeight: CGFloat {
        switch player.playlist.mode {
        case .referenced:
            .zero
        case .canonical:
            300
        }
    }

    private var controlsOpacity: CGFloat {
        if contentSize.height >= containerSize.height + metadataHeight {
            switch player.playlist.mode {
            case .referenced:
                1.0
            case .canonical:
                max(0, min(1, -scrollOffset / (metadataHeight / 2)))
            }
        } else {
            1.0
        }
    }

    // MARK: - Leading Actions

    @ViewBuilder private func leadingActions() -> some View {
        HStack(spacing: 2) {
            // MARK: Clear Selection

            Button {
                handleEscape()
            } label: {
                Image(systemSymbol: .xmark)
            }
            .disabled(!canEscape)
            .aspectRatio(6 / 5, contentMode: .fit)

            // MARK: Remove Selection from Playlist / Remove All

            Button(role: .destructive) {
                if canEscape {
                    handleRemove(player.selectedTracks.map(\.url))
                } else {
                    handleRemove(player.playlist.map(\.url))
                }

                resetFocus(in: namespace) // Must regain focus due to unknown reasons
            } label: {
                HStack {
                    Image(systemSymbol: .trashFill)

                    if !canRemove || !canEscape {
                        Text("Clear Playlist")
                    } else {
                        Text("Remove from Playlist")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.luminareProminent)
            .foregroundStyle(.red)
            .fixedSize(horizontal: true, vertical: false)
            .disabled(!canRemove)
        }
        .buttonStyle(.luminare)
    }

    // MARK: - Trailing Actions

    @ViewBuilder private func trailingActions() -> some View {
        HStack(spacing: 2) {
            // MARK: Playback Mode

            Button {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(
                    negate: hasShift)
            } label: {
                PlaybackModeView(mode: player.playbackMode)
                    .padding()
            }
            .fixedSize(horizontal: true, vertical: false)

            // MARK: Playback Looping

            Button {
                player.playbackLooping.toggle()
            } label: {
                Image(systemSymbol: .repeat1)
                    .aliveHighlight(player.playbackLooping)
                    .luminareAnimation(.instant)
            }
            .aspectRatio(6 / 5, contentMode: .fit)
        }
        .buttonStyle(.luminare)
    }

    // MARK: - Item View

    @ViewBuilder private func itemView(for track: Track) -> some View {
        let isInitialized = track.metadata.state.isInitialized
        let isModified = track.metadata.isModified

        TrackView(
            track: track,
            isSelected: player.selectedTracks.contains(track)
        )
        .redacted(reason: track.metadata.state == .loading ? .placeholder : [])
        .contextMenu {
            contextMenu(for: track)
        }
        .swipeActions {
            if isInitialized {
                // MARK: Play

                Button {
                    player.play(track.url)
                } label: {
                    Image(systemSymbol: .play)
                }
                .tint(.accent)

                // MARK: Remove from Playlist

                Button(role: .destructive) {
                    handleRemove([track.url])
                } label: {
                    Image(systemSymbol: .trash)
                }
                .tint(.red)
            }
        }
        .swipeActions(edge: .leading) {
            if isInitialized {
                // MARK: Save Metadata

                if isModified {
                    Button {
                        Task {
                            try await track.metadata.write()
                        }
                    } label: {
                        Image(systemSymbol: .trayAndArrowDown)
                        Text("Save Metadata")
                    }
                    .tint(.green)
                }

                // MARK: Restore Metadata

                if isModified {
                    Button {
                        track.metadata.restore()
                    } label: {
                        Image(systemSymbol: .arrowUturnLeft)
                        Text("Restore Metadata")
                    }
                    .tint(.red)
                }

                // MARK: Reload Metadata

                Button {
                    Task {
                        try await track.metadata.update()
                    }
                } label: {
                    Image(systemSymbol: .trayAndArrowUp)
                    Text("Reload Metadata")
                }
                .tint(.accent)
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder private func contextMenu(for track: Track) -> some View {
        let isInitialized = track.metadata.state.isInitialized
        let isModified = track.metadata.isModified

        // MARK: Play

        Button {
            player.play(track.url)
        } label: {
            let title = MusicTitle.stringifiedTitle(mode: .title, for: track)
            if !title.isEmpty {
                Text("Play \(title)")
            } else {
                Text("Play")
            }
        }
        .disabled(!isInitialized)
        .keyboardShortcut(.return, modifiers: [])

        // MARK: Remove from Playlist

        Button("Remove from Playlist") {
            if metadataEditor.hasMetadata {
                handleRemove(player.selectedTracks.map(\.url))
            } else {
                handleRemove([track.url])
            }
        }
        .keyboardShortcut(.deleteForward, modifiers: [])

        Divider()

        // MARK: Save Metadata

        Button("Save Metadata") {
            Task {
                try await track.metadata.write()
            }
        }
        .disabled(!isInitialized || !isModified)
        .keyboardShortcut("s", modifiers: .command)

        // MARK: Restore Metadata

        Button("Restore Metadata") {
            track.metadata.restore()
        }
        .disabled(!isInitialized || !isModified)

        // MARK: Reload Metadata

        Button("Reload Metadata") {
            Task {
                try await track.metadata.update()
            }
        }
        .keyboardShortcut("r", modifiers: .command)

        Divider()

        Button("Reveal in Finder") {
            NSWorkspace.shared.activateFileViewerSelecting([track.url])
        }
    }

    // MARK: - Functions

    private func toggleBounceAnimation(for track: Track) {
        if bounceAnimationTriggers.contains(track) {
            bounceAnimationTriggers.remove(track)
        } else {
            bounceAnimationTriggers.insert(track)
        }
    }

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        player.selectedTracks.removeAll()
        return true
    }

    @discardableResult private func handleRemove(_ urls: [URL]) -> Bool {
        guard canRemove else { return false }
        player.removeFromPlaylist(urls)
        return true
    }
}

#if DEBUG

    // MARK: - Preview

    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        @Previewable @Namespace var namespace

        PlaylistView(namespace: namespace)
    }
#endif
