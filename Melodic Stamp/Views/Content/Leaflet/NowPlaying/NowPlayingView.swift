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
    @State private var showLyrics: Bool = false

    var body: some View {
        HStack {
            if let thumbnail = player.current?.metadata.thumbnail {
                MusicCover(
                    images: [thumbnail], hasPlaceholder: false,
                    cornerRadius: 20
                )
                .frame(width: isPlaying ? 300 : 250, height: isPlaying ? 300 : 250)
                .shadow(radius: isPlaying ? 20 : 10)
                .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
                .padding(.leading, showLyrics ? 50 : 0)
            }
            
            NowPlayingLyricsView(currentTime: playbackTime?.elapsed ?? 0)
                .transition(.blurReplace(.downUp))
        }
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
    }
}
