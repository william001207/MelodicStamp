//
//  PlaylistView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import SwiftUI
import Luminare
import SFSafeSymbols

struct PlaylistView: View {
    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel
    
    var body: some View {
        AutoScrollView(.vertical) {
            LuminareList(
                items: $player.playlist,
                selection: $metadataEditor.items,
                id: \.id
            ) { item in
                PlaylistItemView(
                    player: player,
                    item: item.wrappedValue,
                    isSelected: metadataEditor.items.contains(item.wrappedValue)
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
                        player.removeFromPlaylist(urls: [item.wrappedValue.url])
                    } label: {
                        Image(systemSymbol: .trash)
                        Text("Delete")
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
                    player.playbackMode = player.playbackMode.cycle(negate: hasShift)
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
                Image(systemSymbol: .trashFill)
            }
            .luminareBordered(false)
            .luminareMinHeight(54)
            .luminareButtonCornerRadius(8)
            
            Spacer()
                .frame(height: 72)
        }
        .contentMargins(.top, 48)
    }
}
