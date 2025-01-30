//
//  PlaylistMetadataView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/30.
//

import Luminare
import SwiftUI

struct PlaylistMetadataView: View {
    @Environment(\.luminareAnimationFast) private var animationFast

    @FocusState private var isTitleFocused: Bool

    var playlist: Playlist
    @Binding var segments: Playlist.Segments

    @State private var isTitleHovering: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var isDescriptionSheetPresented: Bool = false

    var body: some View {
        HStack(spacing: 25) {
            Button {
                isImagePickerPresented = true
            } label: {
                artworkView()
                    .motionCard()
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
                    try? playlist.write(segments: [.artwork])
                case .failure:
                    break
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 5)

            VStack(alignment: .leading) {
                titleView()
                    .font(.title)

                Button {
                    isDescriptionSheetPresented = true
                } label: {
                    descriptionView()
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.alive)
                .sheet(isPresented: $isDescriptionSheetPresented) {
                    try? playlist.write(segments: [.info])
                } content: {
                    // In order to make safe area work, we need a wrapper
                    ScrollView {
                        LuminareTextEditor(text: $segments.info.description)
                            .luminareBordered(false)
                            .luminareHasBackground(false)
                            .scrollDisabled(true)
                    }
                    .scrollContentBackground(.hidden)
                    .scrollClipDisabled()
                    .presentationAttachmentBar(edge: .top, attachment: controls)
                    .presentationSizing(.fitted)
                    .frame(minWidth: 725, minHeight: 500, maxHeight: 1200)
                }
            }
        }
        .frame(height: 250)
    }

    @ViewBuilder private func artworkView() -> some View {
        if let artwork = playlist.segments.artwork.image {
            MusicCover(images: [artwork], cornerRadius: 8)
        } else {
            MusicCover(cornerRadius: 8)
        }
    }

    @ViewBuilder private func titleView() -> some View {
        HStack {
            TextField("Playlist Title", text: $segments.info.title)
                .bold()
                .textFieldStyle(.plain)
                .focused($isTitleFocused)
                .onSubmit {
                    isTitleFocused = false
                }

            if !isTitleFocused {
                HStack {
                    if isTitleHovering {
                        Button {
                            NSWorkspace.shared.activateFileViewerSelecting([playlist.possibleURL])
                        } label: {
                            HStack {
                                if let creationDate = try? playlist.possibleURL.attribute(.creationDate) as? Date {
                                    let formattedCreationDate = creationDate.formatted(
                                        date: .complete,
                                        time: .standard
                                    )
                                    Text("Created at \(formattedCreationDate)")
                                }

                                Image(systemSymbol: .folder)
                            }
                            .foregroundStyle(.placeholder)
                        }
                        .buttonStyle(.alive)
                    } else {
                        Text("\(playlist.tracks.count) tracks")
                    }
                }
                .font(.body)
                .foregroundStyle(.placeholder)
            }
        }
        .animation(animationFast, value: isTitleHovering)
        .onHover { hover in
            isTitleHovering = hover
        }
        .onChange(of: isTitleFocused) { _, newValue in
            guard !newValue else { return }
            try? playlist.write(segments: [.info])
        }
    }

    @ViewBuilder private func descriptionView() -> some View {
        let description = segments.info.description

        if !description.isEmpty {
            Text(description)
        } else {
            Image(systemSymbol: .ellipsisCircleFill)
                .imageScale(.large)
                .padding(.vertical, 2)
        }
    }

    @ViewBuilder private func controls() -> some View {
        Group {
            Text("Playlist Description")
                .bold()

            Spacer()

            Button {
                isDescriptionSheetPresented = false
            } label: {
                Text("Done")
            }
            .foregroundStyle(.tint)
        }
        .buttonStyle(.alive)
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var segments: Playlist.Segments = SampleEnvironmentsPreviewModifier.samplePlaylistSegments

        PlaylistMetadataView(
            playlist: SampleEnvironmentsPreviewModifier.samplePlaylist,
            segments: $segments
        )
    }
#endif
