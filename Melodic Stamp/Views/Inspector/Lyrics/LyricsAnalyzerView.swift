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
                    .luminareCompactButtonAspectRatio(1 / 1, contentMode: .fit)
                    .disabled(lyricsAnalyzer.raw.isEmpty)
                    .foregroundStyle(.red)

                    Button("Parse Lyrics") {
                        Task {
                            try await lyricsAnalyzer.parseLyrics()
                        }
                    }
                    .luminareCompactButtonAspectRatio(contentMode: .fill)
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

                                    lyrics(line.lyrics)

                                    if !line.backgroundLyrics.isEmpty {
                                        HStack {
                                            Text("background")
                                                .foregroundStyle(.orange)

                                            Spacer()
                                        }
                                        .font(.caption)
                                        .monospaced()
                                        .foregroundStyle(.secondary)

                                        lyrics(line.backgroundLyrics)
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
    
    @ViewBuilder private func lyrics(_ lyrics: TTMLLyrics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(lyrics.children, id: \.beginTime) { lyric in
                            Text(lyric.text)
                                .bold()
                                .modifier(LuminareHoverable())
                                .luminareBordered(false)
                                .luminareHorizontalPadding(0)
                                .luminareMinHeight(24)
                        }
                    }
                    .padding(.horizontal, 4)
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))
            
            if let translation = lyrics.translation {
                HStack {
                    Image(systemSymbol: .translate)
                    .padding(2)
                    .frame(
                        width: 16, height: 16)
                    
                    Text("\(translation)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .foregroundStyle(.tint)
            }
            
            if let roman = lyrics.roman {
                HStack {
                    Image(systemSymbol: .characterPhonetic)
                    .padding(2)
                    .frame(width: 16, height: 16)
                    
                    Text("\(roman)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .foregroundStyle(.purple)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    LyricsAnalyzerView()
        .frame(minHeight: 850)
}
