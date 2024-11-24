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
    
    @Watched private var cover: NSImage?
    @State private var isCoverPickerPresented: Bool = false
    
    @Watched private var title: MetadataType.Title?
    @Watched private var artist: MetadataType.Artist?
    @Watched private var composer: MetadataType.Composer?
    
    @Watched private var albumTitle: MetadataType.AlbumTitle?
    @Watched private var albumArtist: MetadataType.AlbumArtist?
    
    @Watched private var bpm: MetadataType.BPM?
    @Watched private var trackNumber: MetadataType.TrackNumber?
    @Watched private var trackTotal: MetadataType.TrackTotal?
    @Watched private var discNumber: MetadataType.DiscNumber?
    @Watched private var discTotal: MetadataType.DiscTotal?
    
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
        _cover.reinit(with: item?.metadata.attachedPictures.first?.image)
        
        _title.reinit(with: item?.metadata.title)
        _artist.reinit(with: item?.metadata.artist)
        _composer.reinit(with: item?.metadata.composer)
        
        _albumTitle.reinit(with: item?.metadata.albumTitle)
        _albumArtist.reinit(with: item?.metadata.albumArtist)
        
        _bpm.reinit(with: item?.metadata.bpm)
        _trackNumber.reinit(with: item?.metadata.trackNumber)
        _trackTotal.reinit(with: item?.metadata.trackTotal)
        _discNumber.reinit(with: item?.metadata.discNumber)
        _discTotal.reinit(with: item?.metadata.discTotal)
    }
    
    private func save() {
        guard let lastSelection else { return }
        
        lastSelection.writeMetadata { metadata in
            metadata.removeAllAttachedPictures()
            if let cover = cover?.attachedPicture {
                metadata.attachPicture(cover)
            }
            
            metadata.title = title
            metadata.artist = artist
            metadata.composer = composer
            
            metadata.albumTitle = albumTitle
            metadata.albumArtist = albumArtist
            
            metadata.bpm = bpm
            metadata.trackNumber = trackNumber
            metadata.trackTotal = trackTotal
            metadata.discNumber = discNumber
            metadata.discTotal = discTotal
        }
        
        load(item: lastSelection)
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
        LabeledTextField("Title", text: _title)
        
        LabeledTextField("Artist", text: _artist)
        
        LabeledTextField("Composer", text: _composer)
    }
    
    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField("Album Title", text: _albumTitle)
        
        LabeledTextField("Album Artist", text: _albumArtist)
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
            LabeledTextField("BPM", value: _bpm, format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: _trackNumber, format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Tracks", value: _trackTotal, format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: _discNumber, format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Discs", value: _discTotal, format: .number)
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
