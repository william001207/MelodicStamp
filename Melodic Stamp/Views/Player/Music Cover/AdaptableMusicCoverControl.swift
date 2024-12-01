//
//  AdaptableMusicCoverControl.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import SwiftUI
import CSFBAudioEngine

struct AdaptableMusicCoverControl: View {
    @Namespace private var namespace
    
    var state: MetadataValueState<Set<AttachedPicture>>
    var type: AttachedPicture.`Type`
    var maxResolution: CGFloat? = 128
    
    @State private var isImagePickerPresented: Bool = false
    @State private var isHeaderHovering: Bool = false
    
    var body: some View {
        let attachedPictures: [AttachedPicture] = switch state {
        case .undefined:
            []
        case .fine(let value):
                .init(value.current)
        case .varied(let values):
            values.current.values.flatMap(\.self)
        }
        
        let images = attachedPictures.compactMap(\.image)
        
        AliveButton {
            isImagePickerPresented = true
        } label: {
            MusicCover(
                images: images,
                maxResolution: maxResolution
            )
            .padding(.horizontal, 16)
        }
        .fileImporter(
            isPresented: $isImagePickerPresented,
            allowedContentTypes: [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
        ) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { break }
                defer { url.stopAccessingSecurityScopedResource() }
                
                guard let image = NSImage(contentsOf: url), let attachedPicture = image.attachedPicture(of: type) else { break }
                
                switch state {
                case .undefined:
                    break
                case .fine(let value):
                    value.current = replacingAttachedPictures([attachedPicture], in: value.current)
                case .varied(let values):
                    values.current = values.current.mapValues { attachedPictures in
                        replacingAttachedPictures([attachedPicture], in: attachedPictures)
                    }
                }
            case .failure:
                break
            }
        }
        .padding(.top, 8)
        .overlay(alignment: .top, content: header)
    }
    
    @ViewBuilder private func header() -> some View {
        Group {
            if isHeaderHovering {
                HStack(spacing: 2) {
                    let isModified = switch state {
                    case .undefined: false
                    case .fine(let value): value.isModified
                    case .varied(let values): values.isModified
                    }
                    
                    AliveButton {
                        switch state {
                        case .undefined: break
                        case .fine(let value): value.revert()
                        case .varied(let values): values.revertAll()
                        }
                    } label: {
                        Image(systemSymbol: .arrowUturnLeft)
                    }
                    .disabled(!isModified)
                    
                    AliveButton {
                        switch state {
                        case .undefined:
                            break
                        case .fine(let value):
                            value.current = []
                        case .varied(let values):
                            values.current = values.current.mapValues {
                                removingAttachedPictures(of: [type], in: $0)
                            }
                        }
                    } label: {
                        Image(systemSymbol: .trash)
                    }
                }
                .foregroundStyle(.red)
                .bold()
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background {
                    Rectangle()
                        .fill(.ultraThickMaterial)
                        .clipShape(.capsule)
                        .matchedGeometryEffect(id: "headerBackground", in: namespace)
                }
            } else {
                AttachedPictureType(type: type)
                    .font(.caption)
                    .foregroundStyle(.placeholder)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .clipShape(.capsule)
                            .matchedGeometryEffect(id: "headerBackground", in: namespace)
                    }
            }
        }
        .onHover { hover in
            isHeaderHovering = hover
        }
        .animation(.default, value: isHeaderHovering)
    }
    
    private func replacingAttachedPictures(
        _ newAttachedPictures: [AttachedPicture],
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        let types = newAttachedPictures.map(\.type)
        return attachedPictures.reduce(into: Set<AttachedPicture>()) { result, original in
            if types.contains(original.type), let attachedPicture = newAttachedPictures.first(where: { $0.type == original.type }) {
                result.insert(attachedPicture)
            } else {
                result.insert(original)
            }
        }
    }
    
    private func removingAttachedPictures(
        of types: [AttachedPicture.`Type`],
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        attachedPictures.reduce(into: Set<AttachedPicture>()) { result, original in
            guard !types.contains(original.type) else { return }
            result.insert(original)
        }
    }
}
