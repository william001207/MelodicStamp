//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    
    @Bindable var player: PlayerModel
    
    var body: some View {
        TimelineView(.animation) { context in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: 10) {
                        ForEach(Array(player.lyricLines.enumerated()), id: \.offset) { index, line in
                            VStack(spacing: 2) {
                                if let stringF = line.stringF {
                                    Text(stringF)
                                        .font(lineIsCurrent(index: index) ? .headline : .body)
                                        .foregroundColor(lineIsCurrent(index: index) ? .blue : .primary)
                                }
                                if let stringS = line.stringS {
                                    Text(stringS)
                                        .font(lineIsCurrent(index: index) ? .subheadline : .caption)
                                        .foregroundColor(lineIsCurrent(index: index) ? .gray : .secondary)
                                }
                            }
                            .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: player.currentLyricIndex) { oldIndex, newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
                .onChange(of: player.timeElapsed) { oldValue, newValue in
                    player.updateCurrentLyricIndex(currentTime: newValue)
                }
            }
        }
    }
    private func lineIsCurrent(index: Int) -> Bool {
        index == player.currentLyricIndex
    }
}
