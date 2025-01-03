//
//  LyricsAnalyzerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/7.
//

import Foundation
import Luminare
import SwiftSoup
import SwiftUI

@Observable @MainActor private final class LyricsAnalyzerModel {
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
                                TTMLInspectorLyricLineView(line: line)
                            }
                            .padding(.horizontal, 8)
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
