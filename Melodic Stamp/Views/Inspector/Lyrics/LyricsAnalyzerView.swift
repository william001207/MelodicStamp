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

                                    VStack(alignment: .leading, spacing: 8) {
                                        Group {
                                            ScrollView(.horizontal) {
                                                HStack(spacing: 0) {
                                                    ForEach(
                                                        line.lyrics,
                                                        id: \.beginTime
                                                    ) {
                                                        lyric in
                                                        Text(lyric.text)
                                                            .font(.title2)
                                                            .bold()
                                                            .modifier(
                                                                LuminareHoverable()
                                                            )
                                                            .luminareBordered(
                                                                false
                                                            )
                                                            .luminareHorizontalPadding(
                                                                0)
                                                    }
                                                }
                                                .padding(.horizontal, 4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.quinary)
                                        .clipShape(.rect(cornerRadius: 8))

                                        if let translation = line.translation {
                                            HStack {
                                                Image(systemSymbol: .translate)
                                                    .padding(2)
                                                    .frame(
                                                        width: 16, height: 16)

                                                Text("\(translation)")
                                            }
                                            .font(.subheadline)
                                            .foregroundStyle(.tint)
                                        }

                                        if let roman = line.roman {
                                            HStack {
                                                Image(
                                                    systemSymbol:
                                                        .characterPhonetic
                                                )
                                                .padding(2)
                                                .frame(width: 16, height: 16)

                                                Text("\(roman)")
                                            }
                                            .font(.subheadline)
                                            .foregroundStyle(.purple)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)

                                    if !line.backgroundLyrics.isEmpty {
                                        HStack {
                                            Text("background")
                                                .foregroundStyle(.orange)

                                            Spacer()
                                        }
                                        .font(.caption)
                                        .monospaced()
                                        .foregroundStyle(.secondary)

                                        VStack(alignment: .leading, spacing: 8)
                                        {
                                            Group {
                                                ScrollView(.horizontal) {
                                                    HStack(spacing: 0) {
                                                        ForEach(
                                                            line
                                                                .backgroundLyrics,
                                                            id: \.beginTime
                                                        ) {
                                                            lyric in
                                                            Text(lyric.text)
                                                                .bold()
                                                                .modifier(
                                                                    LuminareHoverable()
                                                                )
                                                                .luminareBordered(
                                                                    false
                                                                )
                                                                .luminareHorizontalPadding(
                                                                    0
                                                                )
                                                                .luminareMinHeight(
                                                                    24)
                                                        }
                                                    }
                                                    .padding(.horizontal, 4)
                                                    .foregroundStyle(.secondary)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(.quinary)
                                            .clipShape(.rect(cornerRadius: 8))

                                            if let translation = line
                                                .backgroundLyrics.translation
                                                .translation
                                            {
                                                HStack {
                                                    Image(
                                                        systemSymbol: .translate
                                                    )
                                                    .padding(2)
                                                    .frame(
                                                        width: 16, height: 16)

                                                    Text("\(translation)")
                                                }
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .foregroundStyle(.tint)
                                            }

                                            if let roman = line.backgroundLyrics
                                                .roman
                                            {
                                                HStack {
                                                    Image(
                                                        systemSymbol:
                                                            .characterPhonetic
                                                    )
                                                    .padding(2)
                                                    .frame(
                                                        width: 16, height: 16)

                                                    Text("\(roman)")
                                                }
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .foregroundStyle(.purple)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }

                                    HStack {
                                        Text("from")

                                        Text(line.beginTime.formatted())

                                        Spacer()

                                        Text("to")

                                        Text(line.endTime.formatted())
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
