//
//  LeafletView.swift
//  Melodic Stamp
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
    @State private var hasLyrics: Bool = true

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            ZStack {
                HStack(spacing: 50) {
                    let images: [NSImage] = if
                        let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image
                    {
                        [cover]
                    } else { [] }
                    
                    MusicCover(
                        images: images, hasPlaceholder: true,
                        cornerRadius: 12
                    )
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
                            Task {
                                dominantColors = try await extractDominantColors(from: cover)
                            }
                        }
                    }
                    
                    if hasLyrics {
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
            // For testing
            .overlay(alignment: .top) {
                HStack {
                    Button("Toggle Lyrics") {
                        withAnimation(.smooth(duration: 0.45)) {
                            hasLyrics.toggle()
                        }
                    }
                    .padding(.top, 100)

                    AudioVisualizer()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }

    private func extractDominantColors(from image: NSImage) async throws -> [Color] {
        let colors = try DominantColors.dominantColors(
            nsImage: image, quality: .low,
            algorithm: .CIE94, maxCount: 3, options: [.excludeBlack], sorting: .lightness
        )
        return colors.map(Color.init(_:))
    }
}
