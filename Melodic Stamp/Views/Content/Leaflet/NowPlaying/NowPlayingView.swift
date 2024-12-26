//
//  NowPlayingView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI
import DominantColors

struct NowPlayingView: View {

    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics

    @State private var dominantColors: [Color] = [Color(hex: 0x929292), Color(hex: 0xFFFFFF), Color(hex: 0x929292)]
    @State private var playbackTime: PlaybackTime?
    @State private var isPlaying: Bool = false
    @State private var showLyrics: Bool = true

    var body: some View {
        HStack(spacing: 75) {
            Group {
                if let thumbnail = player.current?.metadata.thumbnail {
                    MusicCover(
                        images: [thumbnail], hasPlaceholder: false,
                        cornerRadius: 20
                    )
                    .frame(width: isPlaying ? 350 : 300, height: isPlaying ? 350 : 300)
                    .shadow(radius: isPlaying ? 20 : 10)
                    .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
                    .onAppear {
                        extractDominantColors(from: thumbnail)
                    }
                    .onChange(of: player.current) { oldValue, newValue in
                        extractDominantColors(from: thumbnail)
                    }
                }
            }
            .frame(width: 350, height: 350, alignment: .center)
            
            if showLyrics {
                NowPlayingLyricsView(showLyrics: $showLyrics)
                    .transition(.blurReplace(.downUp))
            }
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            AnimatedGrid(CoverColors: dominantColors)
        }
     
        // Test Only
        
        .overlay(alignment: .top) {
            HStack {
                Button("Lyrics Toggle"){
                    withAnimation(.smooth(duration: 0.45)) {
                        showLyrics.toggle()
                    }
                }
                .padding(.top, 100)
                AudioVisualizationView()
                    .frame(width: 20, height: 20)
            }
        }
        
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
    }
    
    func extractDominantColors(from image: NSImage) {
        do {
            let colors = try DominantColors.dominantColors(nsImage: image, quality: .low,algorithm: .CIE94, maxCount: 3, options: [.excludeBlack], sorting: .lightness)
            
            let processedColors = colors.map { nsColor in
                Color(
                    red: Double(nsColor.redComponent),
                    green: Double(nsColor.greenComponent),
                    blue: Double(nsColor.blueComponent)
                )
            }
            self.dominantColors = processedColors
        } catch {
            print("Failed to extract colors: \(error)")
        }
    }
}
