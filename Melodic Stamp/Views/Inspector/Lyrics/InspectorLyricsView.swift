//
//  InspectorLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct InspectorLyricsView: View {
    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics

    @State private var playbackTime: PlaybackTime?

    var body: some View {
        Group {
            switch entries.type {
            case .none, .varied:
                ExcerptView(tab: SidebarInspectorTab.lyrics)
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
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            guard newValue == nil else { return }
            playbackTime = nil
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
        if let timeElapsed = playbackTime?.elapsed {
            lyrics.find(at: timeElapsed, in: player.current?.url)
        } else {
            0 ..< 0
        }
    }

    @ViewBuilder private func lyricLines() -> some View {
        switch lyrics.storage {
        case let .raw(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                rawLyricLine(line: line, index: index)
            }
        case let .lrc(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                lrcLyricLine(line: line, index: index)
            }
        case let .ttml(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) {
                index, line in
                ttmlLyricLine(line: line, index: index)
            }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder private func rawLyricLine(line: RawLyricLine, index _: Int) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine, index: Int) -> some View {
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
            .foregroundStyle(.quinary)

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
        .foregroundStyle(.tint)
        .tint(isHighlighted ? .accent : .secondary)
        .scaleEffect(isHighlighted ? 1.1 : 1)
        .animation(.bouncy, value: isHighlighted)
        .padding(.vertical, 4)
    }

    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine, index: Int)
        -> some View {
        let isHighlighted = highlightedRange.contains(index)

        TTMLInspectorLyricLineView(isHighlighted: isHighlighted, line: line)
    }

    private func loadLyrics() {
        guard let binding = entries.projectedValue else { return }
        lyrics.load(string: binding.wrappedValue)
    }
}
