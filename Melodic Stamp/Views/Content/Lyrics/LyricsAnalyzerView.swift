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
    var lyrics: [TestTtmlLyric] = []
    var raw: String = ""

    func parseLyrics() async throws {
        let parser = TestTTMLParser()
        guard let ttmlData = raw.data(using: .utf8) else { return }
        lyrics = try await parser.decodeTtml(data: ttmlData, coderType: .utf8)
    }
}

// for testing purposes
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
                    .buttonStyle(LuminareCompactButtonStyle())
                    .luminareCompactButtonAspectRatio(1/1, contentMode: .fit)
                    .disabled(lyricsAnalyzer.raw.isEmpty)
                    .foregroundStyle(.red)
                    
                    Button("Parse Lyrics") {
                        Task {
                            try await lyricsAnalyzer.parseLyrics()
                        }
                    }
                    .buttonStyle(LuminareCompactButtonStyle())
                    .luminareCompactButtonAspectRatio(contentMode: .fill)
                    .disabled(lyricsAnalyzer.raw.isEmpty)
                }
            }

            Group {
                if !lyricsAnalyzer.lyrics.isEmpty {
                    ScrollView {
                        DividedVStack {
                            ForEach(lyricsAnalyzer.lyrics) { lyric in
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("#\(lyric.indexNum)")
                                            .foregroundStyle(.orange)
                                        
                                        Spacer()
                                        
                                        Text("at")
                                        
                                        Text("\(lyric.position)")
                                            .foregroundStyle(.orange)
                                    }
                                    .font(.caption)
                                    .monospaced()
                                    .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Group {
                                            if let mainLyrics = lyric.mainLyric {
                                                ScrollView(.horizontal) {
                                                    HStack(spacing: 0) {
                                                        ForEach(mainLyrics, id: \.beginTime) {
                                                            mainLyric in
                                                            Text(mainLyric.text)
                                                                .font(.title2)
                                                                .bold()
                                                            
                                                                .modifier(LuminareHoverable())
                                                                .luminareBordered(false)
                                                                .luminareHorizontalPadding(0)
                                                        }
                                                    }
                                                    .padding(.horizontal, 4)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.quinary)
                                        .clipShape(.rect(cornerRadius: 8))
                                        
                                        if let translation = lyric.translation {
                                            HStack {
                                                Image(systemSymbol: .translate)
                                                    .padding(2)
                                                    .frame(width: 16, height: 16)
                                                
                                                Text("\(translation)")
                                            }
                                            .font(.subheadline)
                                            .foregroundStyle(.tint)
                                        }
                                        
                                        if let roman = lyric.roman {
                                            HStack {
                                                Image(systemSymbol: .characterPhonetic)
                                                    .padding(2)
                                                    .frame(width: 16, height: 16)
                                                
                                                Text("\(roman)")
                                            }
                                            .font(.subheadline)
                                            .foregroundStyle(.purple)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    if let bgLyric = lyric.bgLyric {
                                        HStack {
                                            Text("background")
                                                .foregroundStyle(.orange)
                                            
                                            Spacer()
                                        }
                                        .font(.caption)
                                        .monospaced()
                                        .foregroundStyle(.secondary)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Group {
                                                if let subLyrics = bgLyric.subLyrics {
                                                    ScrollView(.horizontal) {
                                                        HStack(spacing: 0) {
                                                            ForEach(subLyrics, id: \.beginTime) {
                                                                subLyric in
                                                                Text(subLyric.text)
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
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(.quinary)
                                            .clipShape(.rect(cornerRadius: 8))
                                            
                                            if let translation = bgLyric
                                                .translation
                                            {
                                                HStack {
                                                    Image(systemSymbol: .translate)
                                                        .padding(2)
                                                        .frame(width: 16, height: 16)
                                                    
                                                    Text("\(translation)")
                                                }
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .foregroundStyle(.tint)
                                            }
                                            
                                            if let roman = bgLyric.roman {
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
                                    
                                    HStack {
                                        Text("from")
                                        
                                        Text(lyric.beginTime.formatted())
                                        
                                        Spacer()
                                        
                                        Text("to")
                                        
                                        Text(lyric.endTime.formatted())
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
