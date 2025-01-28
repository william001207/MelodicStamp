//
//  LibraryItemView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryItemView: View {
    @Environment(LibraryModel.self) private var library

    var playlist: Playlist
    var isSelected: Bool

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                if hasTitle {
                    Text(playlist.information.info.title)
                        .bold()
                        .font(.title3)

                    Text(playlist.id.shortened)
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                } else {
                    Text("Playlist \(playlist.id.shortened)")
                        .font(.title3)
                        .foregroundStyle(.placeholder)
                }
            }
            .onDoubleClick(handler: makeCurrent)
            .transition(.blurReplace)
            .opacity(opacity)

            Spacer()

            if !isCurrentPlaylist {
                Button {
                    makeCurrent()
                } label: {
                    coverView()
                }
                .buttonStyle(.alive)
            } else {
                coverView()
            }
        }
        .padding(6)
        .padding(.trailing, -1)
        .background {
            Color.clear
                .onDoubleClick(handler: makeCurrent)
        }
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }

    private var opacity: CGFloat {
        if isSelected || isCurrentPlaylist {
            1
        } else {
            0.65
        }
    }

    private var isCurrentPlaylist: Bool {
        library.currentPlaylist == playlist
    }

    private var hasTitle: Bool {
        !playlist.information.info.title.isEmpty
    }

    @ViewBuilder private func coverView() -> some View {
        ZStack {
            if
                let tiffRepresentation = playlist.information.artwork.tiffRepresentation,
                let image = NSImage(data: tiffRepresentation) {
                MusicCover(
                    images: [image], hasPlaceholder: false, cornerRadius: 4
                )
                .overlay {
                    if isHovering, !isCurrentPlaylist {
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(0.25)
                            .blendMode(.darken)
                    }
                }

                if isHovering, !isCurrentPlaylist {
                    Image(systemSymbol: .rectangleStackFill)
                        .foregroundStyle(.white)
                }
            } else {
                if isHovering, !isCurrentPlaylist {
                    Image(systemSymbol: .rectangleStackFill)
                        .foregroundStyle(.primary)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 4))
        .frame(width: 50, height: 50)
        .font(.title3)
        .contentTransition(.symbolEffect(.replace))
    }

    private func makeCurrent() {
        library.currentPlaylist = playlist
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        LibraryItemView(playlist: SampleEnvironmentsPreviewModifier.samplePlaylist, isSelected: false)
    }
#endif
