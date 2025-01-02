//
//  MiniPlayerLyrics.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/28.
//

import SwiftUI

struct MiniPlayerLyrics: View {
    
    @Environment(PlayerModel.self) private var player
    @Environment(LyricsModel.self) private var lyrics
    
    @State private var playbackTime: PlaybackTime?
    @State private var elapsedTime: TimeInterval = 0.0
        
    private var highlightedRange: Range<Int> {
        lyrics.highlight(at: elapsedTime)
    }
    
    var body: some View {
        HStack {
            let lines = lyrics.lines
            let highlightedRange = highlightedRange
            
            if !highlightedRange.isEmpty {
                ForEach(highlightedRange, id: \.self) { index in
                    lyricLine(line: lines[index], index: index)
                }
            } else {
                Text("No lyrics available")
            }
        }
        .animation(.linear, value: elapsedTime) // For text rendering
        .onReceive(player.playbackTimePublisher) { playbackTime in
            guard let playbackTime else { return }
            elapsedTime = playbackTime.elapsed
        }
    }
    
    @ViewBuilder private func lyricLine(
        line: any LyricLine, index: Int
    ) -> some View {
        Group {
            switch line {
            case let line as RawLyricLine:
                rawLyricLine(line: line)
            case let line as LRCLyricLine:
                lrcLyricLine(line: line)
            case let line as TTMLLyricLine:
                ttmlLyricLine(line: line)
            default:
                EmptyView()
            }
        }
        .bold()
        .lineLimit(1)
        .foregroundStyle(Color.black)
    }
    
    @ViewBuilder private func rawLyricLine(line: RawLyricLine) -> some View {
        Text(line.content)
               
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
        Text(line.content)
    }
    
    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine) -> some View {
        let lyricsRenderer = textRenderer(for: line.lyrics)
        Text(stringContent(of: line.lyrics))
            .textRenderer(lyricsRenderer)
    }
    
    private func stringContent(of lyrics: TTMLLyrics) -> String {
        lyrics.map(\.content).joined()
    }
    
    private func textRenderer(for lyrics: TTMLLyrics) -> some TextRenderer {
        DisplayLyricsRenderer(
            elapsedTime: elapsedTime,
            strings: lyrics.children, vowels: lyrics.vowels,
            inactiveOpacity: 0.25,
            brightness: 0,
            lift: 0
        )
    }
}

#Preview {
    MiniPlayerLyrics()
}
