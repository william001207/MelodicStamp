//
//  NowPlayingView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

struct NowPlayingView: View {

    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics

    @State private var playbackTime: PlaybackTime?
    @State private var isPlaying: Bool = false
    @State private var showLyrics: Bool = true

    var body: some View {
        HStack(spacing: 50) {
            Group {
                if let thumbnail = player.current?.metadata.thumbnail {
                    MusicCover(
                        images: [thumbnail], hasPlaceholder: false,
                        cornerRadius: 20
                    )
                    .frame(width: isPlaying ? 350 : 300, height: isPlaying ? 350 : 300)
                    .shadow(radius: isPlaying ? 20 : 10)
                    .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
                }
            }
            .frame(width: 350, height: 350, alignment: .center)
            
            if showLyrics {
                NowPlayingLyricsView()
                    .transition(.blurReplace(.downUp))
            }
        }
        .padding(.horizontal, 100)
        .background(Color.black.opacity(0.5))
        // Test Only
        .overlay(alignment: .top) {
            Button("Lyrics Toggle"){
                withAnimation(.smooth(duration: 0.45)) {
                    showLyrics.toggle()
                }
            }
            .padding(.top, 100)
        }
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
    }
}
