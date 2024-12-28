//
//  DisplayLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Luminare
import SwiftUI

struct DisplayLyricsView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(LyricsModel.self) private var lyrics

    @Environment(\.luminareAnimation) private var animation

    @State private var playbackTime: PlaybackTime?

    @State private var highlightedRange: Range<Int> = 0..<0
    @State private var isPlaying: Bool = false
    @State private var isHovering: Bool = false

    @State private var fineGrainedElapsedTime: TimeInterval = 0.0
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    
    var body: some View {
        // Avoid multiple instantializations
        let lines = lyrics.lines

        let range = highlightedRange

        Group {
            if !lines.isEmpty {
                BouncyScrollView(
                    bounceDelay: 0.2,
                    range: 0 ..< lines.count,
                    highlightedRange: range,
                    alignment: .center
                ) { index, isHighlighted in
                    lyricLine(line: lines[index], index: index, isHighlighted: isHighlighted)

                } indicator: { index, _ in
                        //.invisible
                    let span = lyrics.storage?.parser.duration(before: index)
                    let beginTime = span?.begin
                    let endTime = span?.end
                    
                    if let beginTime, let endTime {
                        let duration = endTime - beginTime
                        let progress = (fineGrainedElapsedTime - beginTime) / duration
                        
                        return if duration >= 4, progress <= 1 {
                            .visible {
                                HStack {
                                    ProgressDotsContainerView(elapsedTime: fineGrainedElapsedTime, beginTime: beginTime, endTime: endTime)
                                    
                                    ProgressView(value: max(0, progress))
                                }
                            }
                        } else { .invisible }
                    } else { return .invisible }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.clear
            }
        }
        .onHover { hover in
            withAnimation(.smooth(duration: 0.45)) {
                isHovering = hover
            }
        }
        .onChange(of: player.current, initial: true) { _, newValue in
            if let newValue {
                connectTimer()

                Task {
                    let raw = await newValue.metadata.poll(for: \.lyrics).current
                    await lyrics.read(raw)
                }
            } else {
                playbackTime = nil
                disconnectTimer()
            }
        }
        .onChange(of: isPlaying, initial: true) { _, newValue in
            if newValue {
                connectTimer()
            } else {
                disconnectTimer()
            }
        }
        .onChange(of: playbackTime) { _, newValue in
            guard let elapsed = newValue?.elapsed else { return }
            fineGrainedElapsedTime = elapsed
            if self.range != highlightedRange {
                highlightedRange = self.range
            }
        }
        .onReceive(player.isPlayingPublisher) { isPlaying in
            self.isPlaying = isPlaying
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
            if let timeElapsed = playbackTime?.elapsed {
                fineGrainedElapsedTime = timeElapsed
            }
        }
        .onReceive(timer) { _ in
            fineGrainedElapsedTime += 0.01
        }
    }

    private var range: Range<Int> {
        if let timeElapsed = playbackTime?.elapsed {
            return lyrics.highlight(at: timeElapsed)
        } else {
            return 0 ..< 0
        }
    }

    @ViewBuilder private func lyricLine(line: any LyricLine, index: Int, isHighlighted: Bool) -> some View {
        VStack(spacing: .zero) {
            switch line {
            case let line as RawLyricLine:
                rawLyricLine(line: line, index: index, isHighlighted: isHighlighted)
            case let line as LRCLyricLine:
                lrcLyricLine(line: line, index: index, isHighlighted: isHighlighted)
            case let line as TTMLLyricLine:
                ttmlLyricLine(line: line, index: index, isHighlighted: isHighlighted)
            default:
                EmptyView()
            }
        }
        .padding(.bottom, 32)
        .blur(radius: isHighlighted || isHovering ? 0 : blurRadius(for: index))
        .opacity(isHighlighted || isHovering ? 1 : opacity(for: index))
    }

    @ViewBuilder private func rawLyricLine(line: RawLyricLine, index _: Int, isHighlighted _: Bool)
        -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine, index _: Int, isHighlighted _: Bool)
        -> some View {
        if line.isValid {
            HStack {
                Text(line.content)
                    .font(.system(size: 36))
                    .bold()
            }
        }
    }

    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine, index _: Int, isHighlighted: Bool)
        -> some View {
        TTMLDisplayLyricLineView(
            line: line, elapsedTime: fineGrainedElapsedTime,
            isHighlighted: isHighlighted
        )
    }

    private func connectTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    }

    private func disconnectTimer() {
        timer.upstream.connect().cancel()
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - (highlightedRange.lowerBound))
        let maxOpacity = 0.55
        let minOpacity = 0.125
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
