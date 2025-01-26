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

    @Environment(PlayerKeyboardControlModel.self) private var playerKeyboardControl
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareAnimation) private var animation

    // MARK: - Fields

    var namespace: Namespace.ID

    @State private var bounceAnimationTriggers: Set<Track> = []

    // MARK: - Body

    var body: some View {
        @Bindable var metadataEditor = metadataEditor

        // `ScrollPosition` isn't working for `List`
        ScrollViewReader { proxy in
            Group {
                if player.isPlaylistEmpty {
                    ExcerptView(tab: SidebarContentTab.playlist)
                } else {
                    // MARK: List

                    List(selection: $metadataEditor.tracks) {
                        // This is much more stable than `.contentMargins()`
                        Spacer()
                            .frame(height: minHeight)
                            .listRowSeparator(.hidden)

                        ForEach(player.playlist, id: \.self) { track in
                            itemView(for: track)
                                .id(track)
                                .draggable(track) {
                                    TrackPreview(track: track)
                                }
                                .bounceAnimation(bounceAnimationTriggers.contains(track), scale: .init(width: 1.01, height: 1.01))
                        }
                        .onMove { indices, destination in
                            withAnimation {
                                player.movePlaylist(fromOffsets: indices, toOffset: destination)
                            }
                        }
                        .transition(.slide)
                    }
                    .scrollClipDisabled()
                    .scrollContentBackground(.hidden)
                    .animation(.default, value: player.playlist)
                    .animation(.default, value: metadataEditor.tracks)

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
                        if handleRemove(tracks: .init(metadataEditor.tracks)) {
                            .handled
                        } else {
                            .ignored
                        }
                    }

                    // Handle [⏎] -> play
                    .onKeyPress(.return) {
                        if metadataEditor.tracks.count == 1, let track = metadataEditor.tracks.first {
                            player.play(track: track)
                            return .handled
                        } else {
                            return .ignored
                        }
                    }

                    // Handle [space] -> toggle play / pause
                    .onKeyPress(keys: [.space], phases: .all) { key in
                        playerKeyboardControl.handlePlayPause(
                            phase: key.phase, modifiers: key.modifiers
                        )
                    }

                    // Handle [← / →] -> adjust progress
                    .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
                        let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

                        return playerKeyboardControl.handleProgressAdjustment(
                            phase: key.phase, modifiers: key.modifiers, sign: sign
                        )
                    }

                    // Handle [↑ / ↓] -> adjust volume
                    .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
                        let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus

                        return playerKeyboardControl.handleVolumeAdjustment(
                            phase: key.phase, modifiers: key.modifiers, sign: sign
                        )
                    }

                    // Handle [m] -> toggle muted
                    .onKeyPress(keys: ["m"], phases: .down) { _ in
                        player.isMuted.toggle()
                        return .handled
                    }
                }
            }
            .overlay(alignment: .top) {
                // MARK: Controls

                HStack(spacing: 0) {
                    Group {
                        LuminareSection(hasPadding: false) {
                            leadingActions(in: proxy)
                                .frame(height: minHeight)
                        }

                        Spacer()

                        LuminareSection(hasPadding: false) {
                            trailingActions(in: proxy)
                                .frame(height: minHeight)
                        }
                    }
                    .luminareBordered(false)
                    .luminareButtonMaterial(.thin)
                    .luminareSectionMasked(true)
                    .luminareSectionMaxWidth(nil)
                    .shadow(color: .black.opacity(0.2), radius: 15)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .onChange(of: player.playlist) { oldValue, newValue in
                let addedTracks = Set(newValue).subtracting(oldValue)

                if let firstAddedTrack = addedTracks.first {
                    withAnimation {
                        proxy.scrollTo(firstAddedTrack, anchor: .center)
                    }
                }
                addedTracks.forEach(toggleBounceAnimation(for:))
            }
        }
    }

    private var canEscape: Bool {
        metadataEditor.hasMetadatas
    }

    private var canLocate: Bool {
        player.hasCurrentTrack
    }

    private var canRemove: Bool {
        !player.playlist.isEmpty
    }

    // MARK: - Leading Actions

    @ViewBuilder private func leadingActions(in proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 2) {
            // MARK: Clear Selection

            Button {
                handleEscape()
            } label: {
                Image(systemSymbol: .xmark)
                    .padding()
            }
            .aspectRatio(1 / 1, contentMode: .fit)
            .disabled(!canEscape)

            // MARK: Locate Selection

            Button {
                handleLocate(in: proxy)
            } label: {
                Image(systemSymbol: .scope)
                    .padding()
            }
            .aspectRatio(1 / 1, contentMode: .fit)
            .disabled(!canLocate)

            // MARK: Remove Selection from Playlist / Remove All

            Button(role: .destructive) {
                if canEscape {
                    handleRemove(tracks: .init(metadataEditor.tracks))
                } else {
                    handleRemove(tracks: player.playlist)
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

    @ViewBuilder private func trailingActions(in _: ScrollViewProxy) -> some View {
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
                    .padding()
            }
            .aspectRatio(1 / 1, contentMode: .fit)
        }
        .buttonStyle(.luminare)
    }

    // MARK: - Item View

    @ViewBuilder private func itemView(for track: Track) -> some View {
        let isInitialized = track.metadata.state.isInitialized
        let isModified = track.metadata.isModified

        TrackView(
            track: track,
            isSelected: metadataEditor.tracks.contains(track)
        )
        .redacted(reason: track.metadata.state == .loading ? .placeholder : [])
        .contextMenu {
            contextMenu(for: track)
        }
        .swipeActions {
            if isInitialized {
                // MARK: Play

                Button {
                    player.play(track: track)
                } label: {
                    Image(systemSymbol: .play)
                }
                .tint(.accent)

                // MARK: Remove from Playlist

                Button(role: .destructive) {
                    handleRemove(tracks: [track])
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
                    Image(systemSymbol: .arrowUpDoc)
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
            player.play(track: track)
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
            if metadataEditor.hasMetadatas {
                handleRemove(tracks: .init(metadataEditor.tracks))
            } else {
                handleRemove(tracks: [track])
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
        metadataEditor.tracks.removeAll()
        return true
    }

    @discardableResult private func handleLocate(in proxy: ScrollViewProxy) -> Bool {
        guard canLocate else { return false }
        guard let track = player.track else { return false }

        withAnimation {
            proxy.scrollTo(track, anchor: .center)
        }
        toggleBounceAnimation(for: track)

        return true
    }

    @discardableResult private func handleRemove(tracks: [Track]) -> Bool {
        guard canRemove else { return false }
        player.removeFromPlaylist(tracks: tracks)
        tracks.forEach { metadataEditor.tracks.remove($0) }
        return true
    }
}
