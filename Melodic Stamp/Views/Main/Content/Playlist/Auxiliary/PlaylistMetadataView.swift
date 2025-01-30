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
//            if hasArtwork {
//                artworkView()
//                    .motionCard(scale: 1.02, angle: .degrees(5))
//            }

            VStack(alignment: .leading) {
//                titleView()
//                    .font(.title)

//                descriptionView()
                Text("\(playlist.segments)")
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
                .frame(width: 200, height: 200)
                .contentTransition(.symbolEffect(.replace))
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
                        Group {
                            Image(systemSymbol: .folder)

                            if let creationDate = try? playlist.possibleURL.attribute(.creationDate) as? Date {
                                Text(creationDate.formatted())
                            }
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
