//
//  InspectorView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
import Luminare

struct InspectorView: View {
    @Bindable var player: PlayerModel
    
    @Binding var selection: Set<PlaylistItem>
    @Binding var lastSelection: PlaylistItem?
    
    @State private var cover: NSImage?
    @State private var isCoverPickerPresented: Bool = false
    
    var body: some View {
        Group {
            if lastSelection != nil {
                AutoScrollView(.vertical) {
                    VStack {
                        image()
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .contentMargins(.top, 48)
                .contentMargins(.bottom, 72)
            } else {
                EmptyMusicNoteView(systemSymbol: SidebarTab.inspector.systemSymbol)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: lastSelection, initial: true) { oldValue, newValue in
            load(item: newValue)
        }
        .toolbar(content: toolbar)
    }
    
    @ViewBuilder private func image() -> some View {
        if let lastSelection, let cover  {
            AliveButton {
                isCoverPickerPresented = true
            } label: {
                Image(nsImage: cover)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 8))
            }
            .fileImporter(
                isPresented: $isCoverPickerPresented,
                allowedContentTypes: [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
            ) { result in
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else { break }
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    if let newCover = NSImage(contentsOf: url) {
                        self.cover = newCover
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    @ViewBuilder private func toolbar() -> some View {
        Button {
            save()
            if let lastSelection {
                player.reload(items: [lastSelection])
            }
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemSymbol: .trayAndArrowDownFill)
                    .imageScale(.small)
                
                Text("Save")
            }
            .padding(.horizontal, 2)
        }
        
        Button {
            load(item: lastSelection)
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemSymbol: .clockArrowCirclepath)
                    .imageScale(.small)
                
                Text("Revert")
            }
            .padding(.horizontal, 2)
            .foregroundStyle(.red)
        }
    }
    
    private func load(item: PlaylistItem?) {
        cover = item?.metadata.attachedPictures.first?.image
    }
    
    private func save() {
        guard let lastSelection else { return }
        
        if let cover = cover?.attachedPicture {
            lastSelection.writeMetadata { metadata in
                metadata.removeAllAttachedPictures()
                metadata.attachPicture(cover)
            }
        }
    }
}
