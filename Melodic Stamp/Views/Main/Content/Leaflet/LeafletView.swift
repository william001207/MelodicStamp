//
//  LeafletView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/13.
//

import DominantColors
import SwiftUI

struct LeafletView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor
    @Environment(LyricsModel.self) private var lyrics

    @State private var dominantColors: [Color] = [.init(hex: 0x929292), .init(hex: 0xFFFFFF), .init(hex: 0x929292)]
    @State private var playbackTime: PlaybackTime?
    @State private var isPlaying: Bool = false
    @State private var isShowingLyrics: Bool = true

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            ZStack {
                HStack(spacing: 50) {
                    let images: [NSImage] = if
                        let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image {
                        [cover]
                    } else { [] }

                    AliveButton {
                        withAnimation {
                            isShowingLyrics.toggle()
                        }
                    } label: {
                        MusicCover(
                            images: images, hasPlaceholder: true,
                            cornerRadius: 12
                        )
                    }
                    .containerRelativeFrame(.vertical, alignment: .center) { length, axis in
                        switch axis {
                        case .horizontal:
                            length
                        case .vertical:
                            min(500, length * 0.5)
                        }
                    }
                    .scaleEffect(isPlaying ? 1 : 0.85, anchor: .center)
                    .shadow(radius: isPlaying ? 20 : 10)
                    .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
                    .onChange(of: player.currentIndex, initial: true) { _, _ in
                        if let cover = images.first {
                            Task { @MainActor in
                                dominantColors = try await extractDominantColors(from: cover)
                            }
                        }
                    }

                    if isShowingLyrics {
                        DisplayLyricsView()
                            .transition(.blurReplace)
                    }
                }
                .containerRelativeFrame(.horizontal, alignment: .center) { length, axis in
                    switch axis {
                    case .horizontal:
                        let padding = length * 0.1
                        return length - 2 * min(100, padding)
                    case .vertical:
                        return length
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background {
                AnimatedGrid(colors: dominantColors)
            }
            .onReceive(player.isPlayingPublisher) { isPlaying in
                self.isPlaying = isPlaying
            }
        }
    }

    private func extractDominantColors(from image: NSImage) async throws -> [Color] {
        let colors = try DominantColors.dominantColors(
            nsImage: image, quality: .fair,
            algorithm: .CIEDE2000, maxCount: 3, sorting: .lightness
        )
        return colors.map(Color.init)
    }
}
