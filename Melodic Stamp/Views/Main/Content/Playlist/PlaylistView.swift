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

    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareAnimation) private var animation

    // MARK: - Fields

    var namespace: Namespace.ID

    // MARK: - Body

    var body: some View {
        @Bindable var metadataEditor = metadataEditor

        Group {
            if player.isPlaylistEmpty {
                ExcerptView(tab: SidebarContentTab.playlist)
            } else {
                // MARK: List

                List(selection: $metadataEditor.tracks) {
                    Spacer()
                        .frame(height: minHeight)
                        .listRowSeparator(.hidden)

                    ForEach(player.playlist, id: \.self) { track in
                        itemView(for: track)
                            .contextMenu {
                                contextMenu(for: track)
                            }
                            .redacted(reason: track.metadata.state.isLoaded ? [] : .placeholder)
                            .selectionDisabled(!track.metadata.state.isProcessed)
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

                .onKeyPress(.escape) {
                    if handleEscape() {
                        .handled
                    } else {
                        .ignored
                    }
                }
                .onKeyPress(.deleteForward) {
                    if handleRemove(tracks: .init(metadataEditor.tracks)) {
                        .handled
                    } else {
                        .ignored
                    }
                }
                .onKeyPress(.return) {
                    if metadataEditor.tracks.count == 1, let track = metadataEditor.tracks.first {
                        player.play(track: track)
                        return .handled
                    } else {
                        return .ignored
                    }
                }
            }
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
                .shadow(color: .black.opacity(0.25), radius: 32)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private var canEscape: Bool {
        !metadataEditor.tracks.isEmpty
    }

    private var canRemove: Bool {
        !player.playlist.isEmpty
    }

    // MARK: - Leading Actions

    @ViewBuilder private func leadingActions() -> some View {
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

            // MARK: Remove Selection from Playlist / Remove All

            Button(role: .destructive) {
                if metadataEditor.tracks.isEmpty {
                    handleRemove(tracks: player.playlist)
                } else {
                    handleRemove(tracks: .init(metadataEditor.tracks))
                }

                resetFocus(in: namespace) // Must regain focus due to unknown reasons
            } label: {
                HStack {
                    Image(systemSymbol: .trashFill)

                    if !canRemove || metadataEditor.tracks.isEmpty {
                        Text("Clear Playlist")
                    } else {
                        Text("Remove from Playlist")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.luminareProminent)
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
                    .padding()
            }
            .aspectRatio(1 / 1, contentMode: .fit)
        }
        .buttonStyle(.luminare)
    }

    // MARK: - Item View

    @ViewBuilder private func itemView(for track: Track) -> some View {
        TrackView(
            track: track,
            isSelected: metadataEditor.tracks.contains(track)
        )
        .swipeActions {
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
        .swipeActions(edge: .leading) {
            // MARK: Save Metadata

            if track.metadata.isModified {
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

            if track.metadata.isModified {
                Button {
                    track.metadata.restore()
                } label: {
                    Image(systemSymbol: .arrowUturnLeft)
                    Text("Restore Metadata")
                }
                .tint(.gray)
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder private func contextMenu(for track: Track) -> some View {
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
        .keyboardShortcut(.return, modifiers: [])

        // MARK: Remove from Playlist

        Button("Remove from Playlist") {
            if metadataEditor.tracks.isEmpty {
                handleRemove(tracks: [track])
            } else {
                handleRemove(tracks: .init(metadataEditor.tracks))
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
        .disabled(!track.metadata.isModified)
        .keyboardShortcut("s", modifiers: .command)

        // MARK: Restore Metadata

        Button("Restore Metadata") {
            track.metadata.restore()
        }
        .disabled(!track.metadata.isModified)
        .keyboardShortcut("r", modifiers: .command)
    }

    // MARK: - Functions

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        metadataEditor.tracks.removeAll()
        return true
    }

    @discardableResult private func handleRemove(tracks: [Track]) -> Bool {
        guard canRemove else { return false }
        player.removeFromPlaylist(tracks: tracks)
        tracks.forEach { metadataEditor.tracks.remove($0) }
        return true
    }
}
