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
    @Bindable var metadataEditing: MetadataEditingModel
    
    @State private var isCoverPickerPresented: Bool = false
    
    var body: some View {
        Group {
            if metadataEditing.hasEditableMetadata {
                AutoScrollView(.vertical) {
                    VStack(spacing: 24) {
                        coverEditor()
                            .frame(maxWidth: .infinity)
                        
                        LabeledSection {
                            generalEditor()
                        }
                        
                        LabeledSection {
                            albumEditor()
                        } label: {
                            Text("Album")
                        }
                        
                        LabeledSection {
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
        .toolbar(content: toolbar)
    }
    
    @ViewBuilder private func coverEditor() -> some View {
        let coverImages = metadataEditing[extracting: \.coverImages]
        
        switch coverImages {
        case .undefined:
            EmptyView()
        case .fine(let values):
            if !values.current.isEmpty {
                AliveButton {
                    isCoverPickerPresented = true
                } label: {
                    MusicCover(coverImages: values.current)
                }
                .fileImporter(
                    isPresented: $isCoverPickerPresented,
                    allowedContentTypes: [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let urls):
                        let selectedImages: Set<NSImage> = Set(urls.compactMap { url in
                            guard url.startAccessingSecurityScopedResource() else { return nil }
                            defer { url.stopAccessingSecurityScopedResource() }
                            
                            return NSImage(contentsOf: url)
                        })
                        values.current = selectedImages
                    case .failure:
                        break
                    }
                }
            } else {
                Color.yellow
            }
        case .varied(let valueSetter):
            Color.blue
        }
    }
    
    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: metadataEditing[extracting: \.title])
        
        LabeledTextField("Artist", text: metadataEditing[extracting: \.artist])
        
        LabeledTextField("Composer", text: metadataEditing[extracting: \.composer])
    }
    
    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField("Album Title", text: metadataEditing[extracting: \.albumTitle])
        
        LabeledTextField("Album Artist", text: metadataEditing[extracting: \.albumArtist])
    }
    
    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top, trigger: .forceTouch()) {
            switch metadataEditing[extracting: \.bpm] {
            case .fine(let values):
                LuminareStepper(
                    value: .init {
                        CGFloat(values.current ?? .zero)
                    } set: { _ in
                        // do nothing
                    },
                    source: .infinite(),
                    indicatorSpacing: 16,
                    onRoundedValueChange: { oldValue, newValue in
                        values.current = Int(newValue)
                    }
                )
            default:
                EmptyView()
            }
        } badge: {
            LabeledTextField("BPM", value: metadataEditing[extracting: \.bpm], format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: metadataEditing[extracting: \.trackNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Tracks", value: metadataEditing[extracting: \.trackTotal], format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: metadataEditing[extracting: \.discNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Discs", value: metadataEditing[extracting: \.discTotal], format: .number)
        }
    }
    
    @ViewBuilder private func toolbar() -> some View {
        Group {
            Button {
                do {
                    try metadataEditing.writeAll()
                } catch {
                    
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
                metadataEditing.revertAll()
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
