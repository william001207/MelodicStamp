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
    @Environment(\.luminareMinHeight) private var minHeight

    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel

    var body: some View {
        if !player.isPlaylistEmpty {
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
                        Button {
                            player.play(item: item.wrappedValue)
                        } label: {
                            Image(systemSymbol: .play)
                        }
                        .tint(.accentColor)

                        Button {
                            player.removeFromPlaylist(items: [item.wrappedValue])
                        } label: {
                            Image(systemSymbol: .trash)
                        }
                        .tint(.red)
                    }
                    .contextMenu {
                        Button("Play") {
                            player.play(item: item.wrappedValue)
                        }

                        Button("Remove") {
                            if metadataEditor.items.isEmpty {
                                player.removeFromPlaylist(items: [item.wrappedValue])
                            } else {
                                player.removeFromPlaylist(items: .init(metadataEditor.items))
                            }
                        }
                    }
                }
                .luminareHasDividers(false)
                .luminareListContentMargins(top: 64 + minHeight, bottom: 94)
                .luminareListItemHeight(64)
                .luminareListItemCornerRadius(12)
                .luminareListItemHighlightOnHover(false)
                
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
                    .shadow(color: .black.opacity(0.5), radius: 32)
                    
                    Spacer()
                }
                .padding(.top, 64)
            }
            .padding(.horizontal)
        } else {
            PlaylistExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private func actions() -> some View {
        HStack(spacing: 2) {
            Button {
                metadataEditor.items = []
            } label: {
                Image(systemSymbol: .xmark)
                    .padding()
            }
            .aspectRatio(1, contentMode: .fit)
            .disabled(metadataEditor.items.isEmpty)

            Button {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                player.playbackMode = player.playbackMode.cycle(
                    negate: hasShift)
            } label: {
                HStack {
                    player.playbackMode.image

                    switch player.playbackMode {
                    case .single:
                        Text("Single Loop")
                    case .sequential:
                        Text("Sequential")
                    case .loop:
                        Text("Sequential Loop")
                    case .shuffle:
                        Text("Shuffle")
                    }
                }
                .padding()
            }
            .fixedSize(horizontal: true, vertical: false)

            Button {
                player.removeFromPlaylist(items: .init(metadataEditor.items))
            } label: {
                HStack {
                    Image(systemSymbol: .trashFill)
                    Text("Remove from Playlist")
                }
                .padding()
            }
            .buttonStyle(LuminareDestructiveButtonStyle())
            .fixedSize(horizontal: true, vertical: false)
            .disabled(metadataEditor.items.isEmpty)
        }
        .buttonStyle(LuminareButtonStyle())
    }
}
