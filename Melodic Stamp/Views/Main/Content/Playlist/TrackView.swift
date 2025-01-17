//
//  TrackView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import CSFBAudioEngine
import SwiftUI

struct TrackView: View {
    @Environment(PlayerModel.self) private var player

    var track: Track
    var isSelected: Bool

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            let metadataState = track.metadata.state
            let isMetadataModified = track.metadata.isModified

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    switch metadataState {
                    case .loading:
                        Text("Loading…")
                            .foregroundStyle(.placeholder)
                    case .fine, .saving:
                        if isPlaying {
                            MarqueeScrollView(animate: false) {
                                MusicTitle(track: track)
                            }
                        } else {
                            MusicTitle(track: track)
                        }
                    case let .error(error):
                        Group {
                            switch error {
                            case .invalidState:
                                Text("Invalid State")
                            case .noWritingPermission:
                                Text("No Writing Permission")
                            case .noReadingPermission:
                                Text("No Reading Permission")
                            }
                        }
                        .foregroundStyle(.red)
                        .bold()
                    }
                }
                .font(.title3)
                .frame(height: 24)
                .opacity(!player.isPlayable || isPlaying ? 1 : 0.5)

                HStack(alignment: .center, spacing: 4) {
                    if isMetadataModified {
                        Circle()
                            .foregroundStyle(.tint)
                            .tint(isSelected ? .primary : .accent)
                            .padding(2)
                            .animation(nil, value: isSelected)
                    }

                    Text(track.url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                }
                .frame(height: 12)
            }
            .transition(.blurReplace)
            .animation(.default.speed(2), value: metadataState)
            .animation(.default.speed(2), value: isMetadataModified)
            .animation(.default.speed(2), value: isPlaying)

            Spacer()

            AliveButton {
                player.play(track: track)
            } label: {
                cover(isMetadataProcessed: metadataState.isProcessed)
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }

    private var isPlaying: Bool {
        player.track == track
    }

    @ViewBuilder private func cover(isMetadataProcessed: Bool) -> some View {
        ZStack {
            if isMetadataProcessed, let image = track.metadata.thumbnail {
                MusicCover(
                    images: [image], hasPlaceholder: false, cornerRadius: 8
                )
                .overlay {
                    if isHovering {
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(0.25)
                            .blendMode(.darken)
                    }
                }

                if isHovering, isMetadataProcessed {
                    Image(systemSymbol: .playFill)
                        .foregroundStyle(.white)
                }
            } else {
                if isHovering, isMetadataProcessed {
                    Image(systemSymbol: .playFill)
                        .foregroundStyle(.primary)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .frame(width: 50, height: 50)
        .font(.title3)
        .contentTransition(.symbolEffect(.replace))
    }
}
