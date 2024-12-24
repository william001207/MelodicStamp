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
            
            NowPlayingLyricsView()
                .transition(.blurReplace(.downUp))
        }
        .padding(.horizontal, 100)
        .background(Color.accentColor.opacity(0.5))
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
    }
}
