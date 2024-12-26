//
//  NowPlayingLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

struct NowPlayingLyricsView: View {

    @Environment(PlayerModel.self) var player
    @Environment(LyricsModel.self) var lyrics
    
    @Binding var showLyrics: Bool

    @State private var playbackTime: PlaybackTime?
    @State private var highlightedRange: Range<Int> = 0..<0
    @State private var eachTextHeights: [CGFloat] = []
    @State private var scrollViewOffset: CGFloat = 50
    @State private var isPlaying: Bool = false
    @State private var isOnHover: Bool = false
    @State private var timer: Timer?
    @State private var fineGrainedElapsedTime: TimeInterval = 0.0

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

    var body: some View {
        VStack {
            if let lines = lyricsLines {
                DynamicScrollView(
                    offset: scrollViewOffset,
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
            } else {
                Text("No lyrics available")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundStyle(.secondary)
            }
        }
        .onHover{ isOnHover in
            withAnimation(.smooth(duration: 0.45)) {
                self.isOnHover = isOnHover
            }
        }
        .onAppear {
            loadLyrics()
        }
        .onChange(of: player.current) { _, newValue in
            loadLyrics()
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            guard newValue == nil else { return }
            playbackTime = nil
            stopTimer()
        }
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
            toggleTimer(isPlaying: isPlaying)
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime

            if let timeElapsed = playbackTime?.elapsed {
                let newRange = lyrics.find(at: timeElapsed, in: player.current?.url)
                if newRange != 0..<0 {
                    highlightedRange = newRange
                }
                fineGrainedElapsedTime = timeElapsed
            }
        }
    }

    @ViewBuilder
    private func lyricLineView(line: any LyricLine, isHighlighted: Bool, index: Int) -> some View {
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
        .blur(radius: isHighlighted ? 0 : isOnHover ? 0 : blur(for: index))
        .opacity(isHighlighted ? 1 : isOnHover ? 1 : opacity(for: index))
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let height = geometry.size.height
                        if index < eachTextHeights.count {
                            eachTextHeights[index] = height
                        } else {
                            eachTextHeights.append(contentsOf: Array(repeating: 0, count: index - eachTextHeights.count + 1))
                            eachTextHeights[index] = height
                        }
                    }
            }
        }
        .onChange(of: isHighlighted) { oldValue, newValue in
            if isHighlighted {
                guard index + 1 < eachTextHeights.count else { return }
                let nextTextHeights = eachTextHeights[index + 1]
                scrollViewOffset = nextTextHeights
            }
        }
    }

    @ViewBuilder
    private func rawLyricLineView(line: RawLyricLine, isHighlighted: Bool) -> some View {
        Text(line.content)
            .font(.system(size: 36).weight(.bold))
    }

    @ViewBuilder
    private func lrcLyricLineView(line: LRCLyricLine, isHighlighted: Bool) -> some View {
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
        .background(isHighlighted ? Color.accentColor.opacity(0.1) : Color.clear)
    }

    @ViewBuilder
    private func ttmlLyricLineView(line: TTMLLyricLine, isHighlighted: Bool) -> some View {
        PlayingTTMLLyricsLine(isHighlighted: isHighlighted, line: line, elapsedTime: fineGrainedElapsedTime)
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
        showLyrics = true
    }

    private func toggleTimer(isPlaying: Bool) {
        if isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            fineGrainedElapsedTime += 0.01
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func opacity(for index: Int) -> Double {
        let distance = abs(index - (highlightedRange.lowerBound))
        let maxOpacity: Double = 0.55
        let minOpacity: Double = 0.125
        let factor = maxOpacity - (Double(distance) * 0.05)
        return max(minOpacity, min(factor, maxOpacity))
    }

    private func blur(for index: Int) -> CGFloat {
        let distance = abs(index - (highlightedRange.lowerBound))
        let maxBlur: CGFloat = 5.0
        let minBlur: CGFloat = 0.0
        let factor = CGFloat(distance) * 1.0
        return max(minBlur, min(factor, maxBlur))
    }
}
