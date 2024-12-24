//
//  NowPlayingLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

struct NowPlayingLyricsView: View {

    @Environment(PlayerModel.self) var player
    @Environment(MetadataEditorModel.self) var metadataEditor
    @Environment(LyricsModel.self) var lyrics

    @State private var playbackTime: PlaybackTime?
    
    @State private var highlightedRange: Range<Int> = 0..<1 // DEBUG

    var body: some View {
        VStack {
            Group {
                switch entries.type {
                case .none, .varied:
                    EmptyView()
                case .identical:
                    if let lines = lyricsLines {
                        DynamicScrollView(
                            range: 0..<lines.count,
                            highlightedRange: highlightedRange,
                            alignment: .center
                        ) { index, isHighlighted in
                            lyricLineView(line: lines[index], isHighlighted: isHighlighted)
                        } indicators: {
                            EmptyView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("No lyrics available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                VStack {
                    if let lines = lyricsLines {
                        HStack {
                            let upperBound = highlightedRange.upperBound
                            
                            Text("Lower bound: \(highlightedRange.lowerBound)")
                                .fixedSize()
                                .frame(width: 100, alignment: .leading)
                            
                            if upperBound > 0 {
                                Slider(
                                    value: Binding {
                                        Double(highlightedRange.lowerBound)
                                    } set: { newValue in
                                        let newBound = min(Int(newValue), upperBound)
                                        highlightedRange = max(0, newBound)..<upperBound
                                    },
                                    in: 0...Double(upperBound),
                                    step: 1
                                ) {
                                    EmptyView()
                                } minimumValueLabel: {
                                    Text("\(0)")
                                } maximumValueLabel: {
                                    Text("\(upperBound)")
                                }
                                .monospaced()
                            } else {
                                Slider(
                                    value: .constant(0),
                                    in: 0...1,
                                    step: 1
                                ) {
                                    EmptyView()
                                } minimumValueLabel: {
                                    Text("\(0)")
                                } maximumValueLabel: {
                                    Text("\(0)")
                                }
                                .disabled(true)
                                .monospaced()
                            }
                        }
                        .padding()
                        HStack {
                            let lowerBound = highlightedRange.lowerBound
                            
                            Text("Upper bound: \(highlightedRange.upperBound)")
                                .fixedSize()
                                .frame(width: 100, alignment: .leading)
                            
                            if lowerBound < lines.count {
                                Slider(
                                    value: Binding {
                                        Double(highlightedRange.upperBound)
                                    } set: { newValue in
                                        let newBound = max(Int(newValue), lowerBound)
                                        highlightedRange = lowerBound..<min(lines.count, newBound)
                                    },
                                    in: Double(lowerBound)...Double(lines.count),
                                    step: 1
                                ) {
                                    EmptyView()
                                } minimumValueLabel: {
                                    Text("\(lowerBound)")
                                } maximumValueLabel: {
                                    Text("\(lines.count)")
                                }
                                .monospaced()
                            } else {
                                Slider(
                                    value: .constant(1),
                                    in: 0...1,
                                    step: 1
                                ) {
                                    EmptyView()
                                } minimumValueLabel: {
                                    Text("\(lines.count)")
                                } maximumValueLabel: {
                                    Text("\(lines.count)")
                                }
                                .disabled(true)
                                .monospaced()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .padding(.bottom, 94)
        .onChange(of: entries, initial: true) { _, _ in
            loadLyrics()
        }
        .onChange(of: lyrics.type) { _, _ in
            loadLyrics()
        }
        .onChange(of: player.current) { _, newValue in
            lyrics.identify(url: newValue?.url)
        }
        .onReceive(player.playbackTimePublisher) { playbackTime in
            self.playbackTime = playbackTime
        }
        .onChange(of: player.currentIndex, initial: true) { _, newValue in
            guard newValue == nil else { return }
            playbackTime = nil
        }
    }

    private var entries: MetadataBatchEditingEntries<String?> {
        metadataEditor[extracting: \.lyrics]
    }

    /*
    private var highlightedRange: Range<Int> {
        if let timeElapsed = playbackTime?.elapsed {
            return lyrics.find(at: timeElapsed, in: player.current?.url)
        } else {
            return 0..<0
        }
    }
    */

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

    @ViewBuilder
    private func lyricLineView(line: any LyricLine, isHighlighted: Bool) -> some View {
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
    }

    @ViewBuilder
    private func rawLyricLineView(line: RawLyricLine, isHighlighted: Bool) -> some View {
        Text(line.content)
            .foregroundStyle(isHighlighted ? .primary : .secondary)
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
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 4)
        .background(isHighlighted ? Color.accentColor.opacity(0.1) : Color.clear)
        .animation(.bouncy, value: isHighlighted)
    }

    @ViewBuilder
    private func ttmlLyricLineView(line: TTMLLyricLine, isHighlighted: Bool) -> some View {
        PlayingTTMLLyricsLine(isHighlighted: isHighlighted, line: line)
    }

    private func loadLyrics() {
        guard let binding = entries.projectedValue else { return }
        lyrics.load(string: binding.wrappedValue)
    }
}
