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

                    Text(playlist.id.uuidString)
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                } else {
                    HStack {
                        Text("Playlist")
                            .fixedSize()

                        Text(playlist.id.uuidString)
                            .foregroundStyle(.placeholder)
                    }
                    .font(.title3)
                }
            }
            .lineLimit(1)
            .onDoubleClick(handler: makeCurrent)
            .transition(.blurReplace)
            .opacity(opacity)
            .animation(.default.speed(2), value: hasControl)

            Spacer()

            if hasControl {
                if isCurrentPlaylist {
                    coverView()
                } else {
                    Button {
                        makeCurrent()
                    } label: {
                        coverView()
                    }
                    .buttonStyle(.alive)
                }
            }
        }
        .frame(height: 50)
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
        if hasCurrentPlaylist {
            if isSelected || isCurrentPlaylist {
                1
            } else {
                0.65
            }
        } else {
            1
        }
    }

    private var hasCurrentPlaylist: Bool {
        library.currentPlaylist != nil
    }

    private var isCurrentPlaylist: Bool {
        library.currentPlaylist == playlist
    }

    private var hasTitle: Bool {
        !playlist.information.info.title.isEmpty
    }

    private var hasControl: Bool {
        guard !isCurrentPlaylist else { return false }
        return isHovering || playlist.information.artwork.image != nil
    }

    @ViewBuilder private func coverView() -> some View {
        ZStack {
            if let image = playlist.information.artwork.image {
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
