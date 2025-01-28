//
//  LibraryItemView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryItemView: View {
    @Environment(PlayerModel.self) private var player

    @Environment(\.openWindow) private var openWindow

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
            .onDoubleClick(handler: open)
            .transition(.blurReplace)
            .animation(.default.speed(2), value: hasControl)

            Spacer()

            if hasControl {
                if isOpened {
                    coverView()
                } else {
                    Button {
                        open()
                    } label: {
                        coverView()
                    }
                    .buttonStyle(.alive)
                }
            }
        }
        .foregroundStyle(isOpened ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
        .frame(height: 50)
        .padding(6)
        .padding(.trailing, -1)
        .background {
            Color.clear
                .onDoubleClick(handler: open)
        }
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }

    private var isOpened: Bool {
        player.playlist == playlist
    }

    private var hasTitle: Bool {
        !playlist.information.info.title.isEmpty
    }

    private var hasArtwork: Bool {
        playlist.information.artwork.image != nil
    }

    private var hasControl: Bool {
        if isOpened {
            hasArtwork
        } else {
            isHovering || hasArtwork
        }
    }

    @ViewBuilder private func coverView() -> some View {
        ZStack {
            if let image = playlist.information.artwork.image {
                MusicCover(
                    images: [image], hasPlaceholder: false, cornerRadius: 4
                )
                .overlay {
                    if isHovering, !isOpened {
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(0.25)
                            .blendMode(.darken)
                    }
                }

                if isHovering, !isOpened {
                    Image(systemSymbol: .rectangleStackFill)
                        .foregroundStyle(.white)
                }
            } else {
                if isHovering, !isOpened {
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

    private func open() {
        openWindow(
            id: WindowID.content.rawValue,
            value: CreationParameters(playlist: .canonical(playlist.id))
        )
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        LibraryItemView(playlist: SampleEnvironmentsPreviewModifier.samplePlaylist, isSelected: false)
    }
#endif
