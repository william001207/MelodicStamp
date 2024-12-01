//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    @Bindable var metadataEditor: MetadataEditorModel
    @Bindable var lyrics: LyricsModel

    var body: some View {
        Group {
            switch lyricsState {
            case .undefined:
                Color.red
            case .fine:
                TimelineView(.animation) { _ in
                    ScrollViewReader { _ in
                        ScrollView {
                            LazyVStack(alignment: .center, spacing: 10) {
                                lyricLines()
                            }
                            .padding(.horizontal)

                            Spacer()
                                .frame(height: 150)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .contentMargins(.top, 64)
                        .contentMargins(.bottom, 94)
                    }
                }
            case let .varied(valueSetter):
                Color.blue
            }
        }
        .onChange(of: lyricsState, initial: true) { _, _ in
            loadLyrics()
        }
        .onChange(of: lyrics.type) { _, _ in
            loadLyrics()
        }
    }

    private var lyricsState: MetadataValueState<String?> {
        metadataEditor[extracting: \.lyrics]
    }

    @ViewBuilder private func lyricLines() -> some View {
        switch lyrics.storage {
        case let .raw(parser):
            ForEach(parser.lines) { line in
                rawLyricLine(line: line)
            }
        case let .lrc(parser):
            ForEach(parser.lines) { line in
                lrcLyricLine(line: line)
            }
        case let .ttml(parser):
            ForEach(parser.lines) { line in
                ttmlLyricLine(line: line)
            }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder private func rawLyricLine(line _: RawLyricLine) -> some View {}

    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
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

            if line.isValid && !line.content.isEmpty {
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
    }

    @ViewBuilder private func ttmlLyricLine(line _: TTMLLyricLine) -> some View {}

    private func loadLyrics() {
        switch lyricsState {
        case let .fine(values):
            do {
                try lyrics.load(string: values.current)
            } catch {}
        default:
            break
        }
    }
}
