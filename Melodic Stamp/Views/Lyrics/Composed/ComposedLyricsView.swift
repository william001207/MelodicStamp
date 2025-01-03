//
//  ComposedLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/28.
//

import SwiftUI

struct ComposedLyricsView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(LyricsModel.self) private var lyrics

    @State private var playbackTime: PlaybackTime?
    @State private var elapsedTime: TimeInterval = 0.0

    var body: some View {
        Group {
            let highlightedRange = highlightedRange
            let index = highlightedRange.upperBound - 1
            let line = lyrics.lines[index]

            if highlightedRange.contains(index), !line.content.isEmpty {
                ComposedLyricLineView(
                    line: line, index: index,
                    highlightedRange: highlightedRange,
                    elapsedTime: elapsedTime
                )
            } else {
                ProgressDotsView(elapsedTime: 0, beginTime: 0, endTime: 0)
                    .scaleEffect(0.7)
            }
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            guard let playbackTime else { return }
            elapsedTime = playbackTime.elapsed
        }
        .animation(.linear, value: elapsedTime) // For time interpolation
    }

    private var highlightedRange: Range<Int> {
        lyrics.highlight(at: elapsedTime)
    }
}
