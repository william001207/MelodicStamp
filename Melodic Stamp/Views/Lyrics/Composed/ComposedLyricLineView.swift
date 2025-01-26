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
                rawLyricLineView(line: line)
            case let line as LRCLyricLine:
                lrcLyricLineView(line: line)
            case let line as TTMLLyricLine:
                ttmlLyricLineView(line: line)
            default:
                EmptyView()
            }
        }
        .bold()
        .lineLimit(1)
    }

    @ViewBuilder private func rawLyricLineView(line: RawLyricLine) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLineView(line: LRCLyricLine) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func ttmlLyricLineView(line: TTMLLyricLine) -> some View {
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
