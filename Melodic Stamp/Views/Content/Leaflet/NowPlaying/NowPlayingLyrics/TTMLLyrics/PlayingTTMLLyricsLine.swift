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
    var elapsedTime: TimeInterval

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Group {
                if isHighlighted {
                    Text(
                        line.lyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                            .joined()
                    )
                    .font(.system(size: 36).weight(.bold))
                    .textRenderer(
                        TTMLTextRenderer(
                            elapsedTime: elapsedTime,
                            ttmlLyrics: line.lyrics.children
                        )
                    )
                } else {
                    Text(
                        line.lyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                            .joined()
                    )
                    .font(.system(size: 36).weight(.bold))
                }
                
                if !line.lyrics.translations.isEmpty {
                    Text(line.lyrics.translations.map { $0.text }.joined(separator: "\n"))
                        .font(.system(size: 22))
                }
                
                if let roman = line.lyrics.roman {
                    Text(roman)
                        .font(.system(size: 22).weight(.bold))
                }
                
                if !line.backgroundLyrics.children.isEmpty && isHighlighted {
                    Group {
                        if isHighlighted {
                            Text(
                                line.backgroundLyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                                    .joined()
                            )
                            .font(.system(size: 28).weight(.bold))
                            .textRenderer(
                                TTMLTextRenderer(
                                    elapsedTime: elapsedTime,
                                    ttmlLyrics: line.backgroundLyrics.children
                                )
                            )
                        } else {
                            Text(
                                line.backgroundLyrics.children.map { $0.text + String(repeating: " ", count: $0.trailingSpaceCount) }
                                    .joined()
                            )
                            .font(.system(size: 28).weight(.bold))
                        }
                        
                        if !line.backgroundLyrics.translations.isEmpty {
                            Text(line.backgroundLyrics.translations.map { $0.text }.joined(separator: "\n"))
                                .font(.system(size: 22))
                        }
                        
                        if let roman = line.backgroundLyrics.roman {
                            Text(roman)
                                .font(.system(size: 22).weight(.bold))
                        }
                    }
                    .transition(.blurReplace(.downUp))
                }
            }
            .foregroundStyle(isHighlighted ? .white : .white.opacity(0.5))
            .multilineTextAlignment(line.position == .main ? .leading : .trailing)
            .frame(maxWidth: .infinity, alignment: line.position == .main ? .leading : .trailing)
        }
    }
}
