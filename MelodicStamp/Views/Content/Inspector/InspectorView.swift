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
                EmptyMusicNoteView(systemSymbol: .photoOnRectangleAngled)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(content: toolbar)
    }
    
    @ViewBuilder private func image() -> some View {
        if let lastSelection, let cover = self.cover ?? lastSelection.metadata.attachedPictures.first?.image {
            AliveButton {
                isCoverPickerPresented = true
            } label: {
                Image(nsImage: cover)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 8))
            }
            .onAppear {
                if self.cover == nil {
                    self.cover = cover
                }
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
            player.reload(items: player.playlist)
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemSymbol: .repeat)
                    .imageScale(.small)
                
                Text("Reload")
            }
            .padding(.horizontal, 2)
        }
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
