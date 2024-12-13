//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel
    @Bindable var lyrics: LyricsModel

    var body: some View {
        Group {
            switch entries.type {
            case .none, .varied:
                EmptyView()
            case .identical:
                TimelineView(.animation) { _ in
                    ScrollViewReader { _ in
                        ScrollView {
                            // do not apply `.contentMargins()`
                            // otherwise causing `LazyVStack` related glitches
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
        }
        // TODO: restore this
//        .onChange(of: entries, initial: true) { _, _ in
//            loadLyrics()
//        }
        .onChange(of: lyrics.type) { _, _ in
            loadLyrics()
        }
        .onChange(of: player.current) { _, newValue in
            lyrics.identify(url: newValue?.url)
        }
    }

    private var alignment: HorizontalAlignment {
        switch lyrics.type {
        case .raw:
            .leading
        case .lrc:
            .center
        case .ttml:
            .leading
        }
    }

    private var entries: MetadataBatchEditingEntries<String?> {
        metadataEditor[extracting: \.lyrics]
    }

    private var highlightedIndices: IndexSet {
        lyrics.find(at: player.timeElapsed, in: player.current?.url)
    }

    @ViewBuilder private func lyricLines() -> some View {
        switch lyrics.storage {
        case let .raw(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) { index, line in
                rawLyricLine(index: index, line: line)
            }
        case let .lrc(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) { index, line in
                lrcLyricLine(index: index, line: line)
            }
        case let .ttml(parser):
            ForEach(Array(parser.lines.enumerated()), id: \.element) { index, line in
                ttmlLyricLine(index: index, line: line)
            }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder private func rawLyricLine(index _: Int, line: RawLyricLine) -> some View {
        Text(line.content)
    }

    @ViewBuilder private func lrcLyricLine(index: Int, line: LRCLyricLine) -> some View {
        let isHighlighted = highlightedIndices.contains(index)

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
        .foregroundStyle(isHighlighted ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
    }

    @ViewBuilder private func ttmlLyricLine(index _: Int, line: TTMLLyricLine) -> some View {
        Text(line.content)
    }

    private func loadLyrics() {
        guard let binding = entries.projectedValue else { return }
        lyrics.load(string: binding.wrappedValue)
    }
}
