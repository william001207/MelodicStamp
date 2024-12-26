//
//  LeafletLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI
import Luminare

struct LeafletLyricsView: View {
    @Environment(PlayerModel.self) var player
    @Environment(LyricsModel.self) var lyrics
    
    @Environment(\.luminareAnimation) private var animation

    @State private var playbackTime: PlaybackTime?
    @State private var highlightedRange: Range<Int> = 0..<0
    @State private var heights: [CGFloat] = []
    @State private var offset: CGFloat = 50

    @State private var isPlaying: Bool = false
    @State private var isHovering: Bool = false

    @State private var fineGrainedElapsedTime: TimeInterval = 0.0
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()

    var body: some View {
        BouncyScrollView(
            offset: offset,
            delayBeforePush: 0.2,
            canPushAnimation: true,
            range: 0..<lyricLines.count,
            highlightedRange: highlightedRange,
            alignment: .center
        ) { index, isHighlighted in
            lyricLine(line: lyricLines[index], index: index, isHighlighted: isHighlighted)
        } indicators: { index, isHighlighted in
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onHover { hover in
            withAnimation(.smooth(duration: 0.45)) {
                isHovering = hover
            }
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            if newValue != nil {
                loadLyrics()
            } else {
                playbackTime = nil
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                connectTimer()
            } else {
                disconnectTimer()
            }
        }
        .onChange(of: playbackTime) { _, newValue in
            guard let elapsed = newValue?.elapsed else { return }
            let newRange = lyrics.find(at: elapsed, in: player.current?.url)
            if newRange != 0..<0 {
                highlightedRange = newRange
            }
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
    
    private var lyricLines: [any LyricLine] {
        switch lyrics.storage {
        case .raw(let parser as any LyricsParser), .lrc(let parser as any LyricsParser), .ttml(let parser as any LyricsParser):
            parser.lines
        default:
            []
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
        .padding(.bottom, 32)
        .blur(radius: isHighlighted || isHovering ? 0 : blurRadius(for: index))
        .opacity(isHighlighted || isHovering ? 1 : opacity(for: index))
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let height = geometry.size.height
                        if index < heights.count {
                            heights[index] = height
                        } else {
                            heights.append(
                                contentsOf: Array(
                                    repeating: 0,
                                    count: index - heights.count + 1))
                            heights[index] = height
                        }
                    }
            }
        }
        .onChange(of: isHighlighted) { oldValue, newValue in
            if isHighlighted {
                guard index + 1 < heights.count else { return }
                let nextHeight = heights[index + 1]
                offset = nextHeight
            }
        }
    }

    @ViewBuilder private func rawLyricLine(line: RawLyricLine, isHighlighted: Bool)
        -> some View
    {
        Text(line.content)
            .font(.system(size: 36).weight(.bold))
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine, isHighlighted: Bool)
        -> some View
    {
        if line.isValid {
            HStack {
                ForEach(line.tags) { tag in
                    if !tag.type.isMetadata {
                        Text(tag.content)
                            .foregroundStyle(.quinary)
                    }
                }
                
                Text(line.content)
                    .font(.system(size: 36))
                    .bold()
            }
        }
    }

    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine, isHighlighted: Bool)
        -> some View
    {
        TTMLDisplayLyricLine(
            line: line, elapsedTime: fineGrainedElapsedTime,
            isHighlighted: isHighlighted
        )
    }

    private func loadLyrics() {
        guard let currentTrack = player.current else {
            return
        }

        guard let lyricsEntry = currentTrack.metadata.lyrics else {
            return
        }

        let lyricsString = lyricsEntry.current
        lyrics.identify(url: currentTrack.url)
        lyrics.load(string: lyricsString)
    }
    
    private func connectTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    }
    
    private func disconnectTimer() {
        timer.upstream.connect().cancel()
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - (highlightedRange.lowerBound))
        let maxOpacity: Double = 0.55
        let minOpacity: Double = 0.125
        let factor = maxOpacity - (Double(distance) * 0.05)
        return max(minOpacity, min(factor, maxOpacity))
    }

    private func blurRadius(for index: Int) -> CGFloat {
        let distance = abs(index - (highlightedRange.lowerBound))
        let maxBlur: CGFloat = 5.0
        let minBlur: CGFloat = 0.0
        let factor = CGFloat(distance) * 1.0
        return max(minBlur, min(factor, maxBlur))
    }
}
