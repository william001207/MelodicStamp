//
//  AdaptableMusicCoverControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI

struct AdaptableMusicCoverControl: View {
    typealias Entries = MetadataBatchEditingEntries<Set<AttachedPicture>>

    @Environment(AttachedPicturesHandlerModel.self) private var attachedPicturesHandler

    @Environment(\.undoManager) private var undoManager

    @Namespace private var namespace

    var entries: Entries
    var type: AttachedPicture.`Type`
    var maxResolution: CGFloat? = 128

    @State private var isImagePickerPresented: Bool = false
    @State private var isHeaderHovering: Bool = false

    var body: some View {
        AliveButton {
            isImagePickerPresented = true
        } label: {
            imageView()
                .motionCard(scale: 1.02, angle: .degrees(3.5), shadowColor: .black.opacity(0.1), shadowRadius: 10)
                .padding(.horizontal, 16)
        }
        .fileImporter(
            isPresented: $isImagePickerPresented,
            allowedContentTypes: AttachedPicturesHandlerModel
                .allowedContentTypes
        ) { result in
            switch result {
            case let .success(url):
                guard url.startAccessingSecurityScopedResource() else { break }
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
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.top, 8)
        .overlay(alignment: .top, content: header)
    }

    private var isModified: Bool {
        attachedPicturesHandler.isModified(
            of: [type], entries: entries
        )
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

    @ViewBuilder private func imageView() -> some View {
        let images: [NSImage] = if let binding = entries.projectedValue {
            [AttachedPicture](binding.wrappedValue)
                .filter { $0.type == type }
                .compactMap(\.image)
        } else { [] }

        MusicCover(images: images, cornerRadius: 8)
            .overlay {
                if isModified {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.clear)
                        .stroke(.tint, lineWidth: 4)
                }
            }
            .clipShape(.rect(cornerRadius: 8))
    }

    private func registerUndo(_ oldValue: Set<AttachedPicture>, for entries: Entries) {
        guard oldValue != entries.projectedValue?.wrappedValue ?? [] else { return }
        undoManager?.registerUndo(withTarget: attachedPicturesHandler) { _ in
            let entries = self.entries
            let fallback = attachedPicturesHandler.copy(contents: entries)
            entries.setAll(oldValue)

            registerUndo(fallback, for: entries)
        }
    }
}

private struct AdaptableMusicCoverControlPreview: View {
    @Environment(MetadataEditorModel.self) private var metadataEditor

    var body: some View {
        AdaptableMusicCoverControl(
            entries: metadataEditor[extracting: \.attachedPictures],
            type: .other
        )
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        @Previewable @State var attachedPicturesHandler: AttachedPicturesHandlerModel = .init()

        AdaptableMusicCoverControlPreview()
            .environment(attachedPicturesHandler)
    }
#endif
