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
                } indicators: { index, _ in
                    let span = lyrics.storage?.parser.duration(after: index)
                    let beginTime = span?.begin ?? .zero
                    let endTime = span?.end ?? player.duration.timeInterval
                    
                    ProgressDotsView(elapsedTime: fineGrainedElapsedTime, beginTime: beginTime, endTime: endTime)
                }
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var highlightedRange: Range<Int> {
        if let timeElapsed = playbackTime?.elapsed {
            lyrics.highlight(at: timeElapsed)
        } else {
            0 ..< 0
        }
    }

    @ViewBuilder private func lyricLine(line: any LyricLine, index: Int, isHighlighted: Bool) -> some View {
        Group {
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
