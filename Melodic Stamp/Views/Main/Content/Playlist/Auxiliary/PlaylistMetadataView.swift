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

    var playlist: Playlist

    @State private var isTitleHovering: Bool = false

    var body: some View {
        HStack(spacing: 25) {
            if hasArtwork {
                artworkView()
                    .frame(width: 200, height: 200)
            }

            VStack(alignment: .leading) {
                titleView()
                    .font(.title)

                descriptionView()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 250)
    }

    private var hasArtwork: Bool {
        playlist.segments.artwork.image != nil
    }

    @ViewBuilder private func artworkView() -> some View {
        if let artwork = playlist.segments.artwork.image {
            MusicCover(images: [artwork], cornerRadius: 4)
                .contentTransition(.symbolEffect(.replace))
                .motionCard()
        }
    }

    @ViewBuilder private func titleView() -> some View {
        let title = playlist.segments.info.title

        HStack(alignment: .center) {
            Group {
                if !title.isEmpty {
                    Text(title)
                } else {
                    Text("Unknown Playlist")
                        .foregroundStyle(.placeholder)
                }
            }
            .bold()

            Spacer()

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
        .animation(animationFast, value: isTitleHovering)
        .onHover { hover in
            isTitleHovering = hover
        }
    }

    @ViewBuilder private func descriptionView() -> some View {
        let description = playlist.segments.info.description

        if !description.isEmpty {
            Text(description)
        }
    }
}

#if DEBUG
    #Preview {
        PlaylistMetadataView(playlist: SampleEnvironmentsPreviewModifier.samplePlaylist)
    }
#endif
