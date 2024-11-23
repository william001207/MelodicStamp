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
    
    @State var selection: Set<PlaylistItem> = []
    @State var lastSelection: PlaylistItem? = nil
    
    @State private var isFileOpenerPresented: Bool = false
    @State private var isFileAdderPresented: Bool = false
    
    var body: some View {
        Group {
            if player.isPlaylistEmpty {
                EmptyMusicNoteView()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        LuminareList(
                            items: $player.playlist,
                            selection: $selection,
                            id: \.id,
                            removeKey: .init("Remove")
                        ) { item in
                            PlaylistItemView(player: player, item: item.wrappedValue, isSelected: selection.contains(item.wrappedValue)) {
                                let hasShift = NSEvent.modifierFlags.contains(.shift)
                                let hasCommand = NSEvent.modifierFlags.contains(.command)
                                handleSelection(of: item.wrappedValue, isShiftPressed: hasShift, isCommandPressed: hasCommand)
                            }
                        } actions: {
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
                        }
                    }
                    .padding(8)
                }
                .contentMargins(.top, 48)
                .contentMargins(.bottom, 72)
            }
        }
        .toolbar(content: toolbar)
    }
    
    @ViewBuilder private func toolbar() -> some View {
        Button {
            isFileOpenerPresented = true
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemSymbol: .playFill)
                    .imageScale(.small)
                
                Text("Open File")
            }
            .padding(.horizontal, 2)
        }
        .fileImporter(isPresented: $isFileOpenerPresented, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: false) { result in
            switch result {
            case .success(let success):
                guard !success.isEmpty else { return }
                player.play(success[0])
            case .failure:
                break
            }
        }
        
        Button {
            isFileAdderPresented = true
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemSymbol: .textLineLastAndArrowtriangleForward)
                    .imageScale(.small)
                
                Text("Add to Playlist")
            }
            .padding(.horizontal, 2)
        }
        .fileImporter(isPresented: $isFileAdderPresented, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: true) { result in
            switch result {
            case .success(let success):
                player.addToPlaylist(urls: success)
            case .failure:
                break
            }
        }
    }
    
    private func handleSelection(of item: PlaylistItem, isShiftPressed: Bool, isCommandPressed: Bool) {
        if isShiftPressed, let last = lastSelection {
            if let startIndex = player.playlist.firstIndex(of: last),
               let endIndex = player.playlist.firstIndex(of: item) {
                let range = min(startIndex, endIndex)...max(startIndex, endIndex)
                let itemsInRange = player.playlist[range]
                selection.formUnion(itemsInRange)
            }
        } else if isCommandPressed {
            if selection.contains(item) {
                selection.remove(item)
            } else {
                selection.insert(item)
            }
        } else {
            selection = [item]
        }
        
        lastSelection = item
    }
}

#Preview {
    PlaylistView(player: .init())
}
