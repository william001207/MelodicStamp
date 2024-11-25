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
    @Bindable var metadataEditor: MetadataEditorModel
    
    @State private var isCoverPickerPresented: Bool = false
    
    var body: some View {
        if metadataEditor.hasEditableMetadata {
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
            InspectorExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder private func coverEditor() -> some View {
        let coverImages = metadataEditor[extracting: \.coverImages]
        
        switch coverImages {
        case .undefined:
            EmptyView()
        case .fine(let values):
            let coverImages = values.current
            AliveButton {
                isCoverPickerPresented = true
            } label: {
                MusicCover(coverImages: coverImages)
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
        case .varied(let valueSetter):
            Color.blue
        }
    }
    
    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: metadataEditor[extracting: \.title])
        
        LabeledTextField("Artist", text: metadataEditor[extracting: \.artist])
        
        LabeledTextField("Composer", text: metadataEditor[extracting: \.composer])
    }
    
    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField("Album Title", text: metadataEditor[extracting: \.albumTitle])
        
        LabeledTextField("Album Artist", text: metadataEditor[extracting: \.albumArtist])
    }
    
    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top, trigger: .forceTouch()) {
            switch metadataEditor[extracting: \.bpm] {
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
            LabeledTextField("BPM", value: metadataEditor[extracting: \.bpm], format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: metadataEditor[extracting: \.trackNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Tracks", value: metadataEditor[extracting: \.trackTotal], format: .number)
        }
        
        HStack {
            LabeledTextField("No.", value: metadataEditor[extracting: \.discNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)
            
            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)
            
            LabeledTextField("Discs", value: metadataEditor[extracting: \.discTotal], format: .number)
        }
    }
}
