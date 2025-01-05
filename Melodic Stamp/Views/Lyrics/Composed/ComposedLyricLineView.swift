//
//  ComposedLyricLineView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/3.
//

import SwiftUI

struct ComposedLyricLineView: View {
    var line: any LyricLine
    var index: Int
    var highlightedRange: Range<Int>
    var elapsedTime: TimeInterval

    var body: some View {
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
    }

    @ViewBuilder private func rawLyricLine(line: RawLyricLine) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine) -> some View {
        let lyricsRenderer = DisplayLyricsRenderer(
            elapsedTime: elapsedTime,
            strings: line.lyrics.children, vowelTimes: line.lyrics.vowelTimes,
            inactiveOpacity: 0.25,
            brightness: 0,
            lift: 0
        )

        Text(line.content)
            .textRenderer(lyricsRenderer)
    }
}
