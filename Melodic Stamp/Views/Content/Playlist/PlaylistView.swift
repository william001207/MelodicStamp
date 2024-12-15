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
    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.luminareMinHeight) private var minHeight

    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel

    var namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .topLeading) {
            LuminareList(
                items: $player.playlist,
                selection: $metadataEditor.items,
                id: \.id
            ) { item in
                PlaylistItemView(
                    player: player,
                    item: item.wrappedValue,
                    isSelected: metadataEditor.items.contains(
                        item.wrappedValue)
                )
                .swipeActions {
                    // Play
                    Button {
                        player.play(item: item.wrappedValue)
                    } label: {
                        Image(systemSymbol: .play)
                    }
                    .tint(.accent)

                    // Remove from playlist
                    Button(role: .destructive) {
                        player.removeFromPlaylist(items: [item.wrappedValue])
                    } label: {
                        Image(systemSymbol: .trash)
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .leading) {
                    // Save metadata
                    if item.wrappedValue.metadata.isModified {
                        Button {
                            Task {
                                try await item.wrappedValue.metadata.write()
                            }
                        } label: {
                            Image(systemSymbol: .trayAndArrowDown)
                            Text("Save Metadata")
                        }
                        .tint(.green)
                    }

                    // Restore metadata
                    if item.wrappedValue.metadata.isModified {
                        Button {
                            item.wrappedValue.metadata.restore()
                        } label: {
                            Image(systemSymbol: .arrowUturnLeft)
                            Text("Restore Metadata")
                        }
                        .tint(.gray)
                    }
                }
                .contextMenu {
                    contextMenu(for: item.wrappedValue)
                }
            } emptyView: {
                PlaylistExcerpt()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .luminareHasDividers(false)
            .luminareListContentMargins(top: 64 + minHeight, bottom: 94)
            .luminareListItemHeight(64)
            .luminareListItemCornerRadius(12)
            .luminareListItemHighlightOnHover(false)
            .contentMargins(.top, 64, for: .scrollIndicators)
            .contentMargins(.bottom, 94, for: .scrollIndicators)
            .animation(.default, value: metadataEditor.items)

            HStack(spacing: 0) {
                LuminareSection(hasPadding: false) {
                    actions()
                        .luminareMinHeight(minHeight)
                        .frame(height: minHeight)
                }
                .luminareBordered(false)
                .luminareButtonMaterial(.ultraThin)
                .luminareSectionMasked(true)
                .luminareSectionMaxWidth(nil)
                .shadow(color: .black.opacity(0.25), radius: 32)

                Spacer()
            }
            .padding(.top, 64)
        }
        .padding(.horizontal)
    }

    @ViewBuilder private func actions() -> some View {
        HStack(spacing: 2) {
            // Clear selection
            Button {
                metadataEditor.items = []
            } label: {
                Image(systemSymbol: .xmark)
                    .padding()
            }
            .aspectRatio(1, contentMode: .fit)
            .disabled(metadataEditor.items.isEmpty)

            // Cycle playback mode
            Button {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(
                    negate: hasShift)
            } label: {
                PlaybackModeView(mode: player.playbackMode)
                    .padding()
            }
            .fixedSize(horizontal: true, vertical: false)

            // Remove selection from playlist
            Button(role: .destructive) {
                player.removeFromPlaylist(items: .init(metadataEditor.items))
                resetFocus(in: namespace) // Must regain focus due to unknown reasons

            } label: {
                HStack {
                    Image(systemSymbol: .trashFill)
                    Text("Remove from Playlist")
                }
                .padding()
            }
            .buttonStyle(.luminareProminent)
            .fixedSize(horizontal: true, vertical: false)
            .disabled(metadataEditor.items.isEmpty)
        }
        .buttonStyle(.luminare)
    }

    @ViewBuilder private func contextMenu(for item: PlaylistItem) -> some View {
        Button("Play") {
            player.play(item: item)
        }

        Button("Remove from Playlist") {
            if metadataEditor.items.isEmpty {
                player.removeFromPlaylist(items: [item])
            } else {
                player.removeFromPlaylist(items: .init(metadataEditor.items))
            }
        }

        Divider()

        Button("Save Metadata") {
            Task {
                try await item.metadata.write()
            }
        }
        .disabled(!item.metadata.isModified)

        Button("Restore Metadata") {
            item.metadata.restore()
        }
        .disabled(!item.metadata.isModified)
    }
}
