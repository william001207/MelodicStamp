//
//  LeafletView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/13.
//

import SwiftUI
import DominantColors

struct LeafletView: View {
    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics
    
    @State private var dominantColors: [Color] = [.init(hex: 0x929292), .init(hex: 0xFFFFFF), .init(hex: 0x929292)]
    @State private var playbackTime: PlaybackTime?
    @State private var isPlaying: Bool = false
    @State private var hasLyrics: Bool = true

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            HStack(spacing: 75) {
                Group {
                    if
                        let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image
                    {
                        MusicCover(
                            images: [cover], hasPlaceholder: false,
                            cornerRadius: 20
                        )
                        .frame(width: isPlaying ? 350 : 300, height: isPlaying ? 350 : 300)
                        .shadow(radius: isPlaying ? 20 : 10)
                        .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
                        .onChange(of: player.currentIndex, initial: true) { _, _ in
                            Task {
                                dominantColors = await extractDominantColors(from: cover)
                            }
                        }
                    }
                }
                .frame(width: 350, height: 350, alignment: .center)
                
                if hasLyrics {
                    LeafletLyricsView()
                        .transition(.blurReplace(.downUp))
                }
            }
            .padding(.horizontal, 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background {
                AnimatedGrid(CoverColors: dominantColors)
            }
            .onReceive(player.isPlayingPublisher) { isPlaying in
                self.isPlaying = isPlaying
            }
            // For testing
            .overlay(alignment: .top) {
                HStack {
                    Button("Toggle Lyrics"){
                        withAnimation(.smooth(duration: 0.45)) {
                            hasLyrics.toggle()
                        }
                    }
                    .padding(.top, 100)
                    
                    AudioVisualizationView()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
    
    func extractDominantColors(from image: NSImage) async -> [Color] {
        do {
            let colors = try DominantColors.dominantColors(
                nsImage: image, quality: .low,
                algorithm: .CIE94, maxCount: 3, options: [.excludeBlack], sorting: .lightness
            )
            
            return colors.map(Color.init(nsColor:))
        } catch {
            print("Failed to extract dominant colors: \(error)")
        }
    }
}
