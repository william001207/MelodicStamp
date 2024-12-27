//
//  TTMLDisplayLyricLine.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI
import Luminare

struct TTMLDisplayLyricLine: View {
    @Environment(\.luminareAnimation) private var animation
    
    var line: TTMLLyricLine
    var elapsedTime: TimeInterval
    var isHighlighted: Bool = false
    
    @State var isAnimationHighlighted: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Group {
                VStack {
                    if isHighlighted {
                        Text(stringContent(of: line.lyrics))
                            .font(.system(size: 36))
                            .bold()
                            .textRenderer(DisplayLyricsRenderer(
                                elapsedTime: elapsedTime,
                                strings: line.lyrics.children
                            ))
                    } else {
                        Text(stringContent(of: line.lyrics))
                            .font(.system(size: 36))
                            .bold()
                            .foregroundStyle(.white.opacity(isAnimationHighlighted ? 1 : 0.1))
                            .brightness(isAnimationHighlighted ? 1.5 : 1.0)
                    }
                }
                .animation(nil, value: isHighlighted)
                
                auxiliaryViews(for: line.lyrics)
                    .font(.system(size: 22))
                
                if !line.backgroundLyrics.children.isEmpty && isHighlighted {
                    Group {
                        Text(stringContent(of: line.backgroundLyrics))
                            .font(.system(size: 28))
                            .bold()
                            .textRenderer(DisplayLyricsRenderer(
                                elapsedTime: elapsedTime,
                                strings: line.backgroundLyrics.children
                            ))
                        
                        auxiliaryViews(for: line.backgroundLyrics)
                            .font(.system(size: 22))
                    }
                    .transition(.blurReplace(.downUp))
                }
            }
            .foregroundStyle(.white.opacity(isHighlighted ? 1 : 0.5))
            .multilineTextAlignment(line.position == .main ? .leading : .trailing)
            .frame(maxWidth: .infinity, alignment: line.position == .main ? .leading : .trailing)
        }
        .onChange(of: isHighlighted) { _, newValue in
            withAnimation(.smooth(duration: 0.45).delay(0.25)) {
                isAnimationHighlighted = newValue
            }
        }
    }
    
    @ViewBuilder private func auxiliaryViews(for lyrics: TTMLLyrics) -> some View {
        ForEach(lyrics.translations) { translation in
            Text(translation.text)
        }
        
        if let roman = lyrics.roman {
            Text(roman)
                .bold()
        }
    }
    
    private func stringContent(of lyrics: TTMLLyrics) -> String {
        lyrics.map(\.content).joined()
    }
}
