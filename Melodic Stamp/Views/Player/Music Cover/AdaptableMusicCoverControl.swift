//
//  AdaptableMusicCoverControl.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI

struct AdaptableMusicCoverControl: View {
    @Namespace private var namespace

    @Bindable var attachedPicturesHandler: AttachedPicturesHandlerModel

    var state: MetadataValueState<Set<AttachedPicture>>
    var type: AttachedPicture.`Type`
    var maxResolution: CGFloat? = 128

    @State private var isImagePickerPresented: Bool = false
    @State private var isHeaderHovering: Bool = false

    var body: some View {
        let attachedPictures: [AttachedPicture] = switch state {
        case .undefined:
            []
        case let .fine(value):
            .init(value.current)
        case let .varied(values):
            values.values.flatMap(\.current)
        }

        let images = attachedPictures
            .filter { $0.type == type }
            .compactMap(\.image)

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
            allowedContentTypes: AttachedPicturesHandlerModel.allowedContentTypes
        ) { result in
            switch result {
            case let .success(url):
                guard url.startAccessingSecurityScopedResource() else { break }
                defer { url.stopAccessingSecurityScopedResource() }

                guard let image = NSImage(contentsOf: url), let attachedPicture = image.attachedPicture(of: type) else { break }
                attachedPicturesHandler.replace([attachedPicture], state: state)
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
                    AliveButton {
                        attachedPicturesHandler.revert(of: [type], state: state)
                    } label: {
                        Image(systemSymbol: .arrowUturnLeft)
                    }
                    .disabled(!attachedPicturesHandler.isModified(of: [type], state: state))

                    AliveButton {
                        attachedPicturesHandler.remove(of: [type], state: state)
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
                AttachedPictureTypeView(type: type)
                    .fixedSize()
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
        .animation(.smooth(duration: 0.25), value: isHeaderHovering)
    }
}
