//
//  PlayingTTMLLyricsLine.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

struct PlayingTTMLLyricsLine: View {

    var isHighlighted: Bool = false
    var line: TTMLLyricLine

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Group {
                Text(
                    line.lyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                        .joined()
                )
                .font(.system(size: 36).weight(.bold))
                
                if !line.lyrics.translations.isEmpty {
                    Text(line.lyrics.translations.map { $0.text }.joined(separator: "\n"))
                        .font(.system(size: 22))
                }
                
                if let roman = line.lyrics.roman {
                    Text(roman)
                        .font(.system(size: 22).weight(.bold))
                }
                
                if !line.backgroundLyrics.children.isEmpty {
                    Text(
                        line.backgroundLyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                            .joined()
                    )
                    .font(.system(size: 28).weight(.bold))
                    
                    if !line.backgroundLyrics.translations.isEmpty {
                        Text(line.backgroundLyrics.translations.map { $0.text }.joined(separator: "\n"))
                            .font(.system(size: 22))
                    }
                    
                    if let roman = line.backgroundLyrics.roman {
                        Text(roman)
                            .font(.system(size: 22).weight(.bold))
                    }
                }
            }
            .blur(radius: isHighlighted ? 0 : 10)
            .foregroundStyle(isHighlighted ? .white : .white.opacity(0.5))
            .multilineTextAlignment(line.position == .main ? .leading : .trailing)
            .frame(maxWidth: .infinity, alignment: line.position == .main ? .leading : .trailing)
        }
    }
}

#Preview {
    VStack {
        PlayingTTMLLyricsLine(isHighlighted: true, line: .init(
            index: 0, position: .main,
            lyrics: .init(
                beginTime: 0, endTime: 1000,
                children: [
                    .init(text: "A", trailingSpaceCount: 1),
                    .init(text: "word", trailingSpaceCount: 1),
                    .init(text: "based", trailingSpaceCount: 1),
                    .init(text: "lyric", trailingSpaceCount: 1),
                    .init(text: "line.")
                ],
                translations: [
                    .init(locale: .init(identifier: "zh-CN"), text: "翻译")
                ],
                roman: "Roman"
            ),
            backgroundLyrics: .init(
                beginTime: 0, endTime: 1000,
                children: [
                    .init(text: "A", trailingSpaceCount: 1),
                    .init(text: "word", trailingSpaceCount: 1),
                    .init(text: "ba", trailingSpaceCount: 0),
                    .init(text: "sed", trailingSpaceCount: 1),
                    .init(text: "back", trailingSpaceCount: 0),
                    .init(text: "ground", trailingSpaceCount: 1),
                    .init(text: "lyric", trailingSpaceCount: 1),
                    .init(text: "line.")
                ],
                translations: [
                    .init(locale: .init(identifier: "zh-CN"), text: "翻译")
                ],
                roman: "Roman"
            )
        ))
    }
    .frame(width: 300)
    .background(Color.gray)
}
