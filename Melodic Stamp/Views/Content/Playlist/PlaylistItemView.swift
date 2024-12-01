//
//  PlaylistItemView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct PlaylistItemView: View {
    @Bindable var player: PlayerModel

    var item: PlaylistItem
    var isSelected: Bool

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            let isMetadataLoaded = item.editableMetadata.state.isLoaded
            let isMetadataModified = item.editableMetadata.isModified

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if isMetadataLoaded {
                        MarqueeScrollView(animate: false) {
                            MusicTitle(item: item)
                        }
                    } else {
                        Text("Loading…")
                            .foregroundStyle(.placeholder)
                    }
                }
                .font(.title3)
                .frame(height: 24)

                HStack(alignment: .center, spacing: 4) {
                    if isMetadataModified {
                        Circle()
                            .foregroundStyle(.tint)
                            .padding(2)
                    }

                    Text(item.url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                }
                .frame(height: 12)
            }
            .transition(.blurReplace)
            .animation(.default.speed(2), value: isMetadataLoaded)
            .animation(.default.speed(2), value: isMetadataModified)

            Spacer()

            AliveButton {
                player.play(item: item)
            } label: {
                ZStack {
                    if isMetadataLoaded {
                        Group {
                            let values = item.editableMetadata[extracting: \.coverImages]

                            MusicCover(cornerRadius: 0, coverImages: values.current, hasPlaceholder: false, maxResolution: 32)
                                .frame(maxWidth: .infinity)
                                .overlay {
                                    if isHovering {
                                        Rectangle()
                                            .foregroundStyle(.placeholder)
                                            .opacity(0.25)
                                            .blendMode(.darken)
                                    }
                                }
                        }
                        .clipShape(.rect(cornerRadius: 6))
                    }

                    if isHovering {
                        Image(systemSymbol: isMetadataLoaded ? .playFill : .playSlashFill)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 12)
        .padding(.trailing, 6)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }
}
