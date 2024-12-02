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
    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel

    var body: some View {
        if !player.isPlaylistEmpty {
            AutoScrollView(.vertical) {
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
                            Text("Play")
                        }
                        .tint(.accentColor)

                        Button {
                            player.removeFromPlaylist(urls: [
                                item.wrappedValue.url
                            ])
                        } label: {
                            Image(systemSymbol: .trash)
                            Text("Remove")
                        }
                        .tint(.red)
                    }
                } actions: {
                    Button {
                        metadataEditor.items = []
                    } label: {
                        Image(systemSymbol: .xmark)
                    }
                    .disabled(!metadataEditor.hasEditableMetadata)
                    .aspectRatio(1, contentMode: .fit)

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
                    }
                } removeView: {
                    HStack {
                        Image(systemSymbol: .trashFill)
                        Text("Remove from Playlist")
                    }
                }
                .luminareBordered(false)
                .luminareSectionMasked(true)
                .luminareListItemCornerRadius(8)
                .luminareListActionsStyle(.borderless)
                .padding(.horizontal)

                Spacer()
                    .frame(height: 150)
            }
            .contentMargins(.top, 64)
            .contentMargins(.bottom, 94)
        } else {
            PlaylistExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
