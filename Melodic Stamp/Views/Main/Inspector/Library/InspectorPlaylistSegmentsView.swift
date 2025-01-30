//
//  InspectorPlaylistSegmentsView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/30.
//

import Luminare
import SwiftUI

struct InspectorPlaylistSegmentsView: View {
    @Binding var segments: Playlist.Segments

    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack(spacing: 25) {
            Button {
                isImagePickerPresented = true
            } label: {
                artworkView()
                    .motionCard()
                    .padding(16)
            }
            .buttonStyle(.alive)
            .fileImporter(
                isPresented: $isImagePickerPresented,
                allowedContentTypes: AttachedPicturesHandlerModel
                    .allowedContentTypes
            ) { result in
                switch result {
                case let .success(url):
                    guard url.startAccessingSecurityScopedResource() else { break }
                    defer { url.stopAccessingSecurityScopedResource() }

                    guard let image = NSImage(contentsOf: url) else { break }
                    segments.artwork.tiffRepresentation = image.tiffRepresentation
                case .failure:
                    break
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 5)
            .frame(maxHeight: 250)

            LabeledSection("Playlist Information") {
                editor()
            }
        }
        .padding()
    }

    @ViewBuilder private func artworkView() -> some View {
        if let artwork = segments.artwork.image {
            MusicCover(images: [artwork], cornerRadius: 8)
        } else {
            MusicCover(cornerRadius: 8)
        }
    }

    @ViewBuilder private func editor() -> some View {
        Group {
            LuminareTextField("Title", text: .init($segments.info.title))

            LuminareTextField("Description", text: .init($segments.info.description))
        }
        .luminareAspectRatio(contentMode: .fill)
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var segments: Playlist.Segments = SampleEnvironmentsPreviewModifier.samplePlaylistSegments

        InspectorPlaylistSegmentsView(segments: $segments)
    }
#endif
