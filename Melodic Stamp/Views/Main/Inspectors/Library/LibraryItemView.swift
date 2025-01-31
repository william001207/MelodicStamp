//
//  LibraryItemView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Luminare
import SwiftUI

struct LibraryItemView: View {
    @Environment(LibraryModel.self) private var library
    @Environment(PlayerModel.self) private var player

    @Environment(\.openWindow) private var openWindow
    @Environment(\.luminareAnimation) private var animation

    var playlist: Playlist
    var isSelected: Bool

    @State private var isHovering: Bool = false

    @State private var bounceAnimationTrigger: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                if hasTitle {
                    Text(playlist.segments.info.title)
                        .bold()
                        .font(.title3)
                } else {
                    Text("Unknown Playlist")
                        .font(.title3)
                        .foregroundStyle(.placeholder)
                }

                HStack {
                    Text("\(playlist.count) Tracks")

                    Text(playlist.id.uuidString)
                        .foregroundStyle(.placeholder)
                }
                .font(.caption)
            }
            .lineLimit(1)
            .onDoubleClick(handler: open)
            .transition(.blurReplace)
            .animation(.default.speed(2), value: hasControl)

            Spacer()

            if hasControl {
                Group {
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
                .animation(nil, value: isHovering)
            }
        }
        .foregroundStyle(isOpened && !isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
        .redacted(reason: library.isLoading ? .placeholder : [])
        .frame(height: 50)
        .padding(6)
        .padding(.trailing, -1)
        .bounceAnimation(bounceAnimationTrigger, scale: .init(width: 1.01, height: 1.01))
        .animation(animation, value: isHovering)
        .background {
            Color.clear
                .onDoubleClick(handler: open)
        }
        .onHover { hover in
            isHovering = hover
        }
        .onAppear {
            bounceAnimationTrigger.toggle()
        }
    }

    private var isOpened: Bool {
        player.playlist == playlist
    }

    private var hasTitle: Bool {
        !playlist.segments.info.title.isEmpty
    }

    private var hasArtwork: Bool {
        playlist.segments.artwork.image != nil
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
            if let artwork = playlist.segments.artwork.image {
                MusicCover(
                    images: [artwork], hasPlaceholder: false, cornerRadius: 4
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
