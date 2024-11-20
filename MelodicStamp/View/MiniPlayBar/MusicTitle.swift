//
//  MusicTitle.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI

struct MusicTitle: View {
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    var body: some View {
        if let nowPlaying = playerViewModel.nowPlaying {
            HStack(spacing: 12) {
                Text(nowPlaying.metadata.title ?? nowPlaying.url.lastPathComponent)
                    .bold()
                Text(nowPlaying.metadata.artist ?? "未知艺术家")
            }
        } else {
            Text("Playlist is Empty")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }
}
