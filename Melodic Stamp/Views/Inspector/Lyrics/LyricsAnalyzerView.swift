//
//  LyricsAnalyzerView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/7.
//

import Foundation
import Luminare
import SwiftSoup
import SwiftUI

@Observable private final class LyricsAnalyzerModel {
    var parser: TTMLParser?
    var raw: String = ""

    func parseLyrics() async throws {
        parser = try .init(string: raw)
    }
}

// For testing purposes
private struct LyricsAnalyzerView: View {
    @State var lyricsAnalyzer = LyricsAnalyzerModel()

    var body: some View {
        VSplitView {
            LuminareSection {
                TextEditor(text: $lyricsAnalyzer.raw)
                    .textEditorStyle(.plain)
                    .padding(2)
                    .background(.quinary)
                    .frame(minWidth: 400, minHeight: 200)
                    .font(.caption)
                    .monospaced()

                HStack(spacing: 2) {
                    Button {
                        lyricsAnalyzer.raw = ""
                    } label: {
                        Image(systemSymbol: .trash)
                    }
                    .luminareAspectRatio(1 / 1, contentMode: .fit)
                    .disabled(lyricsAnalyzer.raw.isEmpty)
                    .foregroundStyle(.red)

                    Button("Parse Lyrics") {
                        Task {
                            try await lyricsAnalyzer.parseLyrics()
                        }
                    }
                    .luminareAspectRatio(contentMode: .fill)
                    .disabled(lyricsAnalyzer.raw.isEmpty)
                }
                .buttonStyle(.luminareCompact)
            }

            Group {
                if let parser = lyricsAnalyzer.parser, !parser.lines.isEmpty {
                    ScrollView {
                        DividedVStack {
                            ForEach(parser.lines) { line in
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
                            .padding(8)
                        }
                    }
                } else {
                    Text("Paste TTML lyrics above...")
                        .foregroundColor(.gray)
                        .italic()
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(minHeight: 300)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    LyricsAnalyzerView()
        .frame(minHeight: 850)
}
