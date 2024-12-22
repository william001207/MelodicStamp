//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics

    @State var timeElapsed: TimeInterval?

    var body: some View {
        Group {
            switch entries.type {
            case .none, .varied:
                EmptyView()
            case .identical:
                ScrollViewReader { _ in
                    ScrollView {
                        // Don't apply `.contentMargins()`, otherwise causing `LazyVStack` related glitches
                        LazyVStack(alignment: alignment, spacing: 10) {
                            lyricLines()
                                .textSelection(.enabled)
                        }
                        .padding(.horizontal)
                        .safeAreaPadding(.top, 64)
                        .safeAreaPadding(.bottom, 94)

                        Spacer()
                            .frame(height: 150)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.top, 64, for: .scrollIndicators)
                    .contentMargins(.bottom, 94, for: .scrollIndicators)
                }
            }
        }
        .onChange(of: entries, initial: true) { _, _ in
            loadLyrics()
        }
        .onChange(of: lyrics.type) { _, _ in
            loadLyrics()
        }
        .onChange(of: player.current) { _, newValue in
            lyrics.identify(url: newValue?.url)
        }
        // Receive playback time update
        .onReceive(player.playbackTime) { playbackTime in
            timeElapsed = playbackTime.current
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            guard newValue == nil else { return }
            timeElapsed = nil
        }
    }

    private var alignment: HorizontalAlignment {
        if let type = lyrics.type {
            switch type {
            case .raw:
                .leading
            case .lrc:
                .center
            case .ttml:
                .leading
            }
        } else {
            .leading
        }
    }

    private var entries: MetadataBatchEditingEntries<String?> {
        metadataEditor[extracting: \.lyrics]
    }

    private var highlightedRange: Range<Int> {
        if let timeElapsed {
            lyrics.find(at: timeElapsed, in: player.current?.url)
        } else {
            0..<0
        }
    }

    @ViewBuilder private func lyricLines() -> some View {
        switch lyrics.storage {
        case let .raw(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                rawLyricLine(index: index, line: line)
            }
        case let .lrc(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                lrcLyricLine(index: index, line: line)
            }
        case let .ttml(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                ttmlLyricLine(index: index, line: line)
            }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder private func rawLyricLine(index _: Int, line: RawLyricLine)
        -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLine(index: Int, line: LRCLine)
        -> some View {
        let isHighlighted = highlightedRange.contains(index)

        HStack {
            ForEach(line.tags) { tag in
                if !tag.type.isMetadata {
                    switch tag.type {
                    case .artist:
                        Text(tag.content)
                    case .album:
                        Text(tag.content)
                    case .title:
                        Text(tag.content)
                    case .author:
                        Text(tag.content)
                    case .creator:
                        Text(tag.content)
                    case .editor:
                        Text(tag.content)
                    case .version:
                        Text(tag.content)
                    default:
                        EmptyView()
                    }
                }
            }
            .foregroundStyle(.secondary)

            if line.isValid, !line.content.isEmpty {
                switch line.type {
                case .main:
                    Text(line.content)
                case let .translation(locale):
                    Text(locale)
                        .foregroundStyle(.placeholder)

                    Text(line.content)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(
            isHighlighted ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
    }

    @ViewBuilder private func ttmlLyricLine(index _: Int, line: TTMLLine)
        -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("#\(line.index)")
                    .foregroundStyle(.orange)

                Spacer()

                Text("at")

                Text("\(line.position)")
                    .foregroundStyle(.orange)
            }
            .font(.caption)
            .monospaced()
            .foregroundColor(.secondary)

            TTMLLyricsView(lyrics: line.lyrics)

            if !line.backgroundLyrics.isEmpty {
                HStack {
                    Text("background")
                        .foregroundStyle(.orange)

                    Spacer()
                }
                .font(.caption)
                .monospaced()
                .foregroundStyle(.secondary)

                TTMLLyricsView(lyrics: line.backgroundLyrics)
            }

            HStack {
                if let beginTime = line.beginTime {
                    Text("from")

                    Text(beginTime.formatted())
                }

                Spacer()

                if let endTime = line.endTime {
                    Text("to")

                    Text(endTime.formatted())
                }
            }
            .font(.caption)
            .monospaced()
            .foregroundColor(.secondary)
        }
    }

    private func loadLyrics() {
        guard let binding = entries.projectedValue else { return }
        lyrics.load(string: binding.wrappedValue)
    }
}
