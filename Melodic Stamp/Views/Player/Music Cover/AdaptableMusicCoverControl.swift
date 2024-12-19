//
//  AdaptableMusicCoverControl.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI

struct AdaptableMusicCoverControl: View {
    typealias Entries = MetadataBatchEditingEntries<Set<AttachedPicture>>

    @Environment(AttachedPicturesHandlerModel.self) var attachedPicturesHandler

    @Environment(\.undoManager) private var undoManager

    @Namespace private var namespace

    var entries: Entries
    var type: AttachedPicture.`Type`
    var maxResolution: CGFloat? = 128

    @State private var isImagePickerPresented: Bool = false
    @State private var isHeaderHovering: Bool = false

    var body: some View {
        Group {
            AliveButton {
                isImagePickerPresented = true
            } label: {
                image()
                    .padding(.horizontal, 16)
            }
            .fileImporter(
                isPresented: $isImagePickerPresented,
                allowedContentTypes: AttachedPicturesHandlerModel
                    .allowedContentTypes
            ) { result in
                switch result {
                case let .success(url):
                    guard url.startAccessingSecurityScopedResource() else {
                        break
                    }
                    defer { url.stopAccessingSecurityScopedResource() }

                    guard
                        let image = NSImage(contentsOf: url),
                        let attachedPicture = image.attachedPicture(of: type)
                    else { break }

                    attachedPicturesHandler.replace(
                        [attachedPicture], entries: entries,
                        undoManager: undoManager
                    )
                case .failure:
                    break
                }
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
                        attachedPicturesHandler.restore(
                            of: [type], entries: entries,
                            undoManager: undoManager
                        )
                    } label: {
                        Image(systemSymbol: .arrowUturnLeft)
                    }
                    .disabled(
                        !attachedPicturesHandler.isModified(
                            of: [type],
                            entries: entries
                        )
                    )

                    AliveButton {
                        attachedPicturesHandler.remove(
                            of: [type], entries: entries,
                            undoManager: undoManager
                        )
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
                        .matchedGeometryEffect(
                            id: "headerBackground", in: namespace
                        )
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
                            .matchedGeometryEffect(
                                id: "headerBackground", in: namespace
                            )
                    }
            }
        }
        .onHover { hover in
            isHeaderHovering = hover
        }
        .animation(.smooth(duration: 0.25), value: isHeaderHovering)
    }

    @ViewBuilder private func image() -> some View {
        if let binding = entries.projectedValue {
            let attachedPictures: [AttachedPicture] = .init(
                binding.wrappedValue)

            let images =
                attachedPictures
                    .filter { $0.type == type }
                    .compactMap(\.image)

            MusicCover(images: images, cornerRadius: 8)
                .background {
                    if attachedPicturesHandler.isModified(
                        of: [type], entries: entries
                    ) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.tint, lineWidth: 8)
                    }
                }
        } else {
            MusicCover(images: [], cornerRadius: 8)
        }
    }

//    private func registerUndo(_ oldValue: Set<AttachedPicture>, for entries: Entries) {
//        guard oldValue != entries.projectedValue?.wrappedValue ?? [] else { return }
//        undoManager?.registerUndo(withTarget: self.attachedPicturesHandler) { _ in
//            let entries = self.entries
//            let fallback = self.attachedPicturesHandler.copy(contents: entries)
//            entries.setAll(oldValue)
//
//            self.registerUndo(fallback, for: entries)
//        }
//    }
}
