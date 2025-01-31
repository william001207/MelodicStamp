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
    @Environment(PlaylistModel.self) private var playlist
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    @Namespace private var coordinateSpace

    // MARK: - Fields

    var namespace: Namespace.ID

    @State private var containerSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var contentOffset: CGFloat = .zero

    @State private var isRemovalAlertPresented: Bool = false

    // MARK: - Body

    var body: some View {
        @Bindable var player = player

        // MARK: List

        List(selection: $player.selectedTracks) {
            Group {
                // MARK: Controls Placeholder

                if playlist.mode.isCanonical {
                    // MARK: Metadata

                    PlaylistMetadataView()
                        .frame(height: metadataHeight)
                        .padding(.horizontal)
                }

                // This is much more stable than `.contentMargins()`
                Spacer()
                    .frame(height: minHeight)
                    .contentOffset($contentOffset, in: coordinateSpace)
                    .onDisappear {
                        contentOffset = .zero
                    }
            }
            .listRowSeparator(.hidden)
            .selectionDisabled()

            // MARK: Tracks

            ForEach(playlist.tracks) { track in
                itemView(for: track)
                    .id(track)
                    .draggable(track) {
                        TrackPreview(track: track)
                    }
            }
            .onMove { indices, destination in
                withAnimation {
                    playlist.move(fromOffsets: indices, toOffset: destination)
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
            .offset(y: max(0, contentOffset - minHeight - 16))
        }
        .animation(animationFast, value: playlist)
        .animation(animationFast, value: player.selectedTracks)

        // MARK: Keyboard Handlers

        // Handles [escape] -> clear selection
        .onKeyPress(.escape) {
            if handleEscape() {
                .handled
            } else {
                .ignored
            }
        }

        // Handles [􁂒] -> remove selection
        .onKeyPress(.deleteForward) {
            if handleRemove(player.selectedTracks.map(\.url)) {
                .handled
            } else {
                .ignored
            }
        }

        // Handles [⏎] -> play
        .onKeyPress(.return) {
            if player.selectedTracks.count == 1, let track = player.selectedTracks.first {
                player.play(track.url)
                return .handled
            } else {
                return .ignored
            }
        }

        // Handles [space] -> toggle play / pause
        .onKeyPress(keys: [.space], phases: .all) { key in
            keyboardControl.handlePlayPause(
                phase: key.phase, modifiers: key.modifiers
            )
        }

        // Handles [← / →] -> adjust progress
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

            return keyboardControl.handleProgressAdjustment(
                phase: key.phase, modifiers: key.modifiers, sign: sign
            )
        }

        // Handles [↑ / ↓] -> adjust volume
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

            return keyboardControl.handleVolumeAdjustment(
                phase: key.phase, modifiers: key.modifiers, sign: sign
            )
        }

        // Handles [m] -> toggle muted
        .onKeyPress(keys: ["m"], phases: .down) { _ in
            player.isMuted.toggle()
            return .handled
        }
    }

    private var canEscape: Bool {
        metadataEditor.hasMetadata
    }

    private var canRemove: Bool {
        playlist.isLoaded
    }

    private var metadataHeight: CGFloat {
        switch playlist.mode {
        case .referenced:
            .zero
        case .canonical:
            300
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

            // MARK: Remove from Playlist

            Group {
                if player.selectedTracks.isEmpty {
                    Button(role: .destructive) {
                        isRemovalAlertPresented = true
                    } label: {
                        HStack {
                            Image(systemSymbol: .trashFill)

                            Text("Clear Playlist")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                } else if player.selectedTracks.count <= 1 {
                    Button(role: .destructive) {
                        handleRemove(player.selectedTracks.map(\.url))
                        resetFocus(in: namespace)
                    } label: {
                        HStack {
                            Image(systemSymbol: .trashFill)

                            Text("Remove from Playlist")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                } else {
                    Button(role: .destructive) {
                        handleRemove(player.selectedTracks.map(\.url))
                        resetFocus(in: namespace)
                    } label: {
                        HStack {
                            Image(systemSymbol: .trashFill)

                            Text("Remove \(player.selectedTracks.count) Tracks from Playlist")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .buttonStyle(.luminareProminent)
            .foregroundStyle(.red)
            .fixedSize(horizontal: true, vertical: false)
            .disabled(!canRemove)
            .alert("Removing All Tracks from Playlist", isPresented: $isRemovalAlertPresented) {
                Button("Proceed", role: .destructive) {
                    Task {
                        await playlist.clear()
                    }
                }
            }
        }
        .buttonStyle(.luminare)
    }

    // MARK: - Trailing Actions

    @ViewBuilder private func trailingActions() -> some View {
        HStack(spacing: 2) {
            // MARK: Playback Mode

            Button {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                playlist.playbackMode = playlist.playbackMode.cycle(negate: hasShift)
            } label: {
                PlaybackModeView(mode: playlist.playbackMode)
                    .padding()
            }
            .fixedSize(horizontal: true, vertical: false)

            // MARK: Playback Looping

            Button {
                playlist.playbackLooping.toggle()
            } label: {
                Image(systemSymbol: .repeat1)
                    .aliveHighlight(playlist.playbackLooping)
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
                if playlist.currentTrack == track {
                    Text("Replay \(title)")
                } else {
                    Text("Play \(title)")
                }
            } else {
                if playlist.currentTrack == track {
                    Text("Replay")
                } else {
                    Text("Play")
                }
            }
        }
        .disabled(!isInitialized)
        .keyboardShortcut(.return, modifiers: [])

        if playlist.mode.isCanonical {
            // MARK: Copy

            Group {
                if player.selectedTracks.count <= 1 {
                    Button("Copy Track") {
                        Task {
                            await copy([track])
                        }
                    }
                } else {
                    Button {
                        Task {
                            await copy(Array(player.selectedTracks))
                        }
                    } label: {
                        Text("Copy \(player.selectedTracks.count) Tracks")
                    }
                }
            }
        }

        // MARK: Remove from Playlist

        Group {
            if player.selectedTracks.count <= 1 {
                Button("Remove from Playlist") {
                    handleRemove([track.url])
                }
            } else {
                Button {
                    handleRemove(player.selectedTracks.map(\.url))
                } label: {
                    Text("Remove \(player.selectedTracks.count) Tracks from Playlist")
                }
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

    private func copy(_ tracks: [Track]) async {
        guard !tracks.isEmpty else { return }

        for track in tracks {
            guard
                let index = playlist.tracks.firstIndex(where: { $0.id == track.id }),
                let copiedTrack = await playlist.createTrack(from: track.url)
            else { continue }
            await playlist.add([copiedTrack.url], at: index + 1)
        }
    }

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        player.selectedTracks.removeAll()
        return true
    }

    @discardableResult private func handleRemove(_ urls: [URL]) -> Bool {
        guard canRemove else { return false }
        Task {
            await playlist.remove(urls)
        }
        return true
    }
}

#if DEBUG

    // MARK: - Preview

    #Preview(traits: .modifier(PreviewEnvironments())) {
        @Previewable @Namespace var namespace

        PlaylistView(namespace: namespace)
    }
#endif
