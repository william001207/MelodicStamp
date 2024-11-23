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
    
    @State var selectedItems: Set<PlaylistItem> = []
    @State var lastSelectedItem: PlaylistItem? = nil
    
    @State private var isFileOpenerPresented: Bool = false
    @State private var isFileAdderPresented: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(player.playlist()) { item in
                    AliveButton {
                        let hasShift = NSEvent.modifierFlags.contains(.shift)
                        let hasCommand = NSEvent.modifierFlags.contains(.command)
                        handleSelection(of: item, isShiftPressed: hasShift, isCommandPressed: hasCommand)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.metadata.title ?? item.url.lastPathComponent)
                                    .font(.headline.bold())
                                Text(item.metadata.artist ?? "Unknown Artist")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(item.url.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            AliveButton {
                                player.play(item)
                            } label: {
                                Image(systemSymbol: .playCircle)
                                    .font(.system(size: 18.0).bold())
                                    .frame(width: 35, height: 35)
                            }
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .background {
                            Group {
                                if selectedItems.contains(item) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue.opacity(0.2))
                                        .stroke(Color.blue, lineWidth: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.quinary)
                                        .stroke(.quinary, lineWidth: 1)
                                }
                            }
                            .animation(.smooth(duration: 0.25), value: selectedItems.contains(item))
                        }
                    }
                    .frame(height: 65)
                }
            }
        }
        .contentMargins(.top, 48)
        .contentMargins(.bottom, 72)
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
        if isShiftPressed, let last = lastSelectedItem {
            if let startIndex = player.playlist().firstIndex(of: last),
               let endIndex = player.playlist().firstIndex(of: item) {
                let range = min(startIndex, endIndex)...max(startIndex, endIndex)
                let itemsInRange = player.playlist()[range]
                selectedItems.formUnion(itemsInRange)
            }
        } else if isCommandPressed {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.insert(item)
            }
        } else {
            selectedItems = [item]
        }
        lastSelectedItem = item
    }
}

#Preview {
    PlaylistView(player: .init())
}
