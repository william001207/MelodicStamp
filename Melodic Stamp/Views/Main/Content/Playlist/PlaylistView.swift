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

        ZStack(alignment: .topLeading) {
            if player.isPlaylistEmpty {
                ExcerptView(tab: SidebarContentTab.playlist)
            } else {
                // MARK: List

                List(selection: $metadataEditor.items) {
                    Spacer()
                        .frame(height: 64 + minHeight)
                        .listRowSeparator(.hidden)

                    ForEach(player.playlist, id: \.self) { item in
                        itemView(for: item)
                            .contextMenu {
                                contextMenu(for: item)
                            }
                            .redacted(reason: item.metadata.state.isLoaded ? [] : .placeholder)
                    }
                    .onMove { indices, destination in
                        withAnimation {
                            player.movePlaylist(fromOffsets: indices, toOffset: destination)
                        }
                    }
                    .transition(.slide)

                    Spacer()
                        .frame(height: 94)
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 64, for: .scrollIndicators)
                .contentMargins(.bottom, 94, for: .scrollIndicators)
                .animation(.default, value: player.playlist)
                .animation(.default, value: metadataEditor.items)

                // MARK: Keyboard Handlers

                .onKeyPress(.escape) {
                    if handleEscape() {
                        .handled
                    } else {
                        .ignored
                    }
                }
                .onKeyPress(.deleteForward) {
                    if handleRemove(items: .init(metadataEditor.items)) {
                        .handled
                    } else {
                        .ignored
                    }
                }
                .onKeyPress(.return) {
                    if metadataEditor.items.count == 1, let item = metadataEditor.items.first {
                        player.play(track: item)
                        return .handled
                    } else {
                        return .ignored
                    }
                }
            }

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
            .padding(.top, 64)
            .padding(.horizontal)
        }
    }

    private var canEscape: Bool {
        !metadataEditor.items.isEmpty
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
                if metadataEditor.items.isEmpty {
                    handleRemove(items: player.playlist)
                } else {
                    handleRemove(items: .init(metadataEditor.items))
                }

                resetFocus(in: namespace) // Must regain focus due to unknown reasons
            } label: {
                HStack {
                    Image(systemSymbol: .trashFill)

                    if !canRemove || metadataEditor.items.isEmpty {
                        Text("Remove All")
                    } else {
                        Text("Remove from Playlist")
                    }
                }
                .padding()
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

    @ViewBuilder private func itemView(for item: Track) -> some View {
        PlayableItemView(
            track: item,
            isSelected: metadataEditor.items.contains(item)
        )
        .swipeActions {
            // MARK: Play

            Button {
                player.play(track: item)
            } label: {
                Image(systemSymbol: .play)
            }
            .tint(.accent)

            // MARK: Remove from Playlist

            Button(role: .destructive) {
                handleRemove(items: [item])
            } label: {
                Image(systemSymbol: .trash)
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading) {
            // MARK: Save Metadata

            if item.metadata.isModified {
                Button {
                    Task {
                        try await item.metadata.write()
                    }
                } label: {
                    Image(systemSymbol: .trayAndArrowDown)
                    Text("Save Metadata")
                }
                .tint(.green)
            }

            // MARK: Restore Metadata

            if item.metadata.isModified {
                Button {
                    item.metadata.restore()
                } label: {
                    Image(systemSymbol: .arrowUturnLeft)
                    Text("Restore Metadata")
                }
                .tint(.gray)
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder private func contextMenu(for item: Track) -> some View {
        // MARK: Play

        Button {
            player.play(track: item)
        } label: {
            let title = MusicTitle.stringifiedTitle(mode: .title, for: item)
            if !title.isEmpty {
                Text("Play \(title)")
            } else {
                Text("Play")
            }
        }
        .keyboardShortcut(.return, modifiers: [])

        // MARK: Remove from Playlist

        Button("Remove from Playlist") {
            if metadataEditor.items.isEmpty {
                handleRemove(items: [item])
            } else {
                handleRemove(items: .init(metadataEditor.items))
            }
        }
        .keyboardShortcut(.deleteForward, modifiers: [])

        Divider()

        // MARK: Save Metadata

        Button("Save Metadata") {
            Task {
                try await item.metadata.write()
            }
        }
        .disabled(!item.metadata.isModified)
        .keyboardShortcut("s", modifiers: .command)

        // MARK: Restore Metadata

        Button("Restore Metadata") {
            item.metadata.restore()
        }
        .disabled(!item.metadata.isModified)
        .keyboardShortcut("r", modifiers: .command)
    }

    // MARK: - Functions

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        metadataEditor.items.removeAll()
        return true
    }

    @discardableResult private func handleRemove(items: [Track]) -> Bool {
        guard canRemove else { return false }
        player.removeFromPlaylist(items: items)
        items.forEach { metadataEditor.items.remove($0) }
        return true
    }
}
