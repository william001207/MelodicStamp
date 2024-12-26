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
        Group {
            if let lines = lyricsLines {
                VStack {
                    BouncyScrollView(
                        offset: offset,
                        delayBeforePush: 0.2,
                        canPushAnimation: true,
                        range: 0..<lines.count,
                        highlightedRange: highlightedRange,
                        alignment: .center
                    ) { index, isHighlighted in
                        lyricLineView(line: lines[index], isHighlighted: isHighlighted, index: index)
                    } indicators: { index, isHighlighted in

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
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

    private var lyricsLines: [any LyricLine]? {
        switch lyrics.storage {
        case let .raw(parser):
            return parser.lines
        case let .lrc(parser):
            return parser.lines
        case let .ttml(parser):
            return parser.lines
        case .none:
            return nil
        }
    }

    @ViewBuilder private func lyricLineView(
        line: any LyricLine, isHighlighted: Bool, index: Int
    ) -> some View {
        Group {
            if let rawLine = line as? RawLyricLine {
                rawLyricLineView(line: rawLine, isHighlighted: isHighlighted)
            } else if let lrcLine = line as? LRCLyricLine {
                lrcLyricLineView(line: lrcLine, isHighlighted: isHighlighted)
            } else if let ttmlLine = line as? TTMLLyricLine {
                ttmlLyricLineView(line: ttmlLine, isHighlighted: isHighlighted)
            } else {
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

    @ViewBuilder private func rawLyricLineView(line: RawLyricLine, isHighlighted: Bool)
        -> some View
    {
        Text(line.content)
            .font(.system(size: 36).weight(.bold))
    }

    @ViewBuilder private func lrcLyricLineView(line: LRCLyricLine, isHighlighted: Bool)
        -> some View
    {
        let tagsView = ForEach(line.tags) { tag in
            if !tag.type.isMetadata {
                Text(tag.content)
                    .foregroundStyle(.quinary)
            }
        }

        HStack {
            tagsView
            if line.isValid, !line.content.isEmpty {
                Text(line.content)
                    .font(.system(size: 36).weight(.bold))
            }
        }
        .background(
            isHighlighted ? Color.accentColor.opacity(0.1) : Color.clear)
    }

    @ViewBuilder private func ttmlLyricLineView(line: TTMLLyricLine, isHighlighted: Bool)
        -> some View
    {
        PlayingTTMLLyricsLine(
            isHighlighted: isHighlighted, line: line,
            elapsedTime: fineGrainedElapsedTime)
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
