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
    
    @State private var isPlaying: Bool = false
    @State private var playbackTime: PlaybackTime?
    @State private var fineGrainedElapsedTime: TimeInterval = 0.0
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    @State private var previousHighlightedRange: Range<Int>? = nil
    
    private var lyricLines: [any LyricLine] {
        switch lyrics.storage {
        case let .raw(parser as any LyricsParser), .lrc(let parser as any LyricsParser), .ttml(let parser as any LyricsParser):
            parser.lines
        default:
            []
        }
    }
    
    private var highlightedRange: Range<Int> {
        if let timeElapsed = playbackTime?.elapsed {
            lyrics.find(at: timeElapsed)
        } else {
            0 ..< 0
        }
    }
    
    private var currentHighlightedRange: Range<Int> {
        highlightedRange.isEmpty ? (previousHighlightedRange ?? 0..<0) : highlightedRange
    }
    
    var body: some View {
        HStack {
            Group {
                if !currentHighlightedRange.isEmpty {
                    ForEach(currentHighlightedRange, id: \.self) { index in
                        let line = lyricLines[index]
                        lyricLine(line: line, index: index, isHighlighted: true)
                    }
                } else {
                    Text("No lyrics available")
                }
            }
            .bold()
            .foregroundColor(.secondary)
        }
        .onChange(of: highlightedRange) { _, newRange in
            if !newRange.isEmpty {
                previousHighlightedRange = newRange
            }
        }
        .onChange(of: player.current, initial: true) { _, newValue in
            if newValue != nil {
                loadLyrics()
                connectTimer()
            } else {
                playbackTime = nil
                disconnectTimer()
            }
        }
        .onChange(of: isPlaying, initial: true) { _, newValue in
            if newValue {
                loadLyrics()
                connectTimer()
            } else {
                disconnectTimer()
            }
        }
        .onChange(of: playbackTime) { _, newValue in
            guard let elapsed = newValue?.elapsed else { return }
            fineGrainedElapsedTime = elapsed
        }
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
        .onReceive(timer) { _ in
            fineGrainedElapsedTime += 0.01
        }
    }
    
    @ViewBuilder private func lyricLine(
        line: any LyricLine, index: Int, isHighlighted: Bool
    ) -> some View {
        Group {
            switch line {
            case let line as RawLyricLine:
                rawLyricLine(line: line, isHighlighted: isHighlighted)
            case let line as LRCLyricLine:
                lrcLyricLine(line: line, isHighlighted: isHighlighted)
            case let line as TTMLLyricLine:
                ttmlLyricLine(line: line, isHighlighted: isHighlighted)
            default:
                EmptyView()
            }
        }
        .transition(.blurReplace(.downUp))
        .animation(.smooth, value: index)
    }
    
    @ViewBuilder private func rawLyricLine(line: RawLyricLine, isHighlighted _: Bool)
        -> some View {
        Text(line.content)
                .lineLimit(1)
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine, isHighlighted _: Bool)
        -> some View {
        if line.isValid {
            HStack {
                Text(line.content)
                    .bold()
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine, isHighlighted: Bool)
        -> some View {
            Group {
                if isHighlighted {
                    Text(stringContent(of: line.lyrics))
                        .bold()
                        .textRenderer(textRenderer(for: line.lyrics))
                        .font(.title3)
                        .lineLimit(1)
                } else {
                    Text(stringContent(of: line.lyrics))
                        .bold()
                        .foregroundStyle(.white.opacity(isHighlighted ? 1 : 0.1))
                        .brightness(isHighlighted ? 1.5 : 1.0)
                        .lineLimit(1)
                }
            }
            .foregroundStyle(Color.secondary)
    }
    
    private func loadLyrics() {
        guard
            let current = player.current,
            let string = current.metadata[extracting: \.lyrics]?.current
        else { return }
        lyrics.load(string: string)
    }

    private func connectTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    }

    private func disconnectTimer() {
        timer.upstream.connect().cancel()
    }
    
    private func stringContent(of lyrics: TTMLLyrics) -> String {
        lyrics.map(\.content).joined()
    }
    
    private func textRenderer(for lyrics: TTMLLyrics) -> some TextRenderer {
        DisplayLyricsRenderer(elapsedTime: fineGrainedElapsedTime, strings: lyrics.children, lift: 0)
    }
}

#Preview {
    MiniPlayerLyrics()
}
