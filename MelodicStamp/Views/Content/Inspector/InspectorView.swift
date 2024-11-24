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
    @Bindable var metadataEditing: MetadataEditingModel = .init()
    
    @Binding var selection: Set<PlaylistItem>
    @Binding var lastSelection: PlaylistItem?
    
    @State private var cover: NSImage?
    @State private var isCoverPickerPresented: Bool = false
    
    @State private var title: MetadataType.Title?
    @State private var artist: MetadataType.Artist?
    @State private var composer: MetadataType.Composer?
    
    @State private var albumTitle: MetadataType.AlbumTitle?
    @State private var albumArtist: MetadataType.AlbumArtist?
    
    @State private var bpm: MetadataType.BPM?
    @State private var trackNumber: MetadataType.TrackNumber?
    @State private var trackTotal: MetadataType.TrackTotal?
    @State private var discNumber: MetadataType.DiscNumber?
    @State private var discTotal: MetadataType.DiscTotal?
    
    var body: some View {
        Group {
            if lastSelection != nil {
                AutoScrollView(.vertical) {
                    VStack(spacing: 24) {
                        coverEditor()
                            .frame(maxWidth: .infinity)
                        
                        EditorSection {
                            generalEditor()
                        }
                        
                        EditorSection {
                            albumEditor()
                        } label: {
                            Text("Album")
                        }
                        
                        EditorSection {
                            trackAndDiscEditor()
                        } label: {
                            Text("Track and Disc")
                        }
                        
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
    
    private func load(item: PlaylistItem?) {
        cover = item?.metadata.attachedPictures.first?.image
        
        title = item?.metadata.title
        artist = item?.metadata.artist
        composer = item?.metadata.composer
        
        albumTitle = item?.metadata.albumTitle
        albumArtist = item?.metadata.albumArtist
        
        bpm = item?.metadata.bpm
        trackNumber = item?.metadata.trackNumber
        trackTotal = item?.metadata.trackTotal
        discNumber = item?.metadata.discNumber
        discTotal = item?.metadata.discTotal
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
    
    @ViewBuilder private func coverEditor() -> some View {
        if let cover  {
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
    
    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: $title)
        
        LabeledTextField("Artist", text: $artist)
        
        LabeledTextField("Composer", text: $composer)
    }
    
    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField("Album Title", text: $albumTitle)
        
        LabeledTextField("Album Artist", text: $albumArtist)
    }
    
    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top, trigger: .forceTouch()) {
            LuminareStepper(
                value: .init {
                    CGFloat(bpm ?? .zero)
                } set: { _ in
                    // do nothing
                },
                source: .infinite(),
                indicatorSpacing: 16,
                onRoundedValueChange: { oldValue, newValue in
                    bpm = Int(newValue)
                }
            )
        } badge: {
            LabeledTextField("BPM", value: $bpm, format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: $trackNumber, format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Tracks", value: $trackTotal, format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: $discNumber, format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Discs", value: $discTotal, format: .number)
        }
    }
    
    @ViewBuilder private func toolbar() -> some View {
        Group {
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
        .background(.thinMaterial)
        .clipShape(.buttonBorder)
    }
}
