//
//  TTMLDisplayLyricLineView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Luminare
import SwiftUI

struct TTMLDisplayLyricLineView: View {
    @Environment(\.luminareAnimation) private var animation

    var line: TTMLLyricLine
    var elapsedTime: TimeInterval
    var isHighlighted: Bool = false

    @State private var isAnimationHighlighted: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            let lyricsRenderer = textRenderer(for: line.lyrics)
            let backgroundLyricsRenderer = textRenderer(for: line.backgroundLyrics)

            // Do not extract any views from inside the if branch, otherwise causing animation loss
            Group {
                if isHighlighted {
                    Text(stringContent(of: line.lyrics))
                        .font(.title)
                        .bold()
                        .textRenderer(lyricsRenderer)

                    additionalContent(for: line.lyrics)
                        .font(.title3)

                    Group {
                        Text(stringContent(of: line.backgroundLyrics))
                            .font(.title2)
                            .bold()
                            .textRenderer(backgroundLyricsRenderer)

                        additionalContent(for: line.backgroundLyrics)
                            .font(.title3)
                    }
                    .transition(.blurReplace)
                } else {
                    Text(stringContent(of: line.lyrics))
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white.opacity(isAnimationHighlighted ? 1 : 0.1))
                        .brightness(isAnimationHighlighted ? 1.5 : 1.0)

                    additionalContent(for: line.lyrics)
                        .font(.title3)

                    Group {
                        Text(stringContent(of: line.backgroundLyrics))
                            .font(.title2)
                            .bold()

                        additionalContent(for: line.backgroundLyrics)
                            .font(.title3)
                    }
                    .transition(.blurReplace)
                }
            }
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: alignment)
        }
        .foregroundStyle(.white.opacity(isHighlighted ? 1 : 0.5))
        .onChange(of: isHighlighted) { _, newValue in
            withAnimation(.smooth(duration: 0.45).delay(0.25)) {
                isAnimationHighlighted = newValue
            }
        }
        // Isolating switching animation between renderers
        .animation(nil, value: isHighlighted)
    }

    private var textAlignment: TextAlignment {
        switch line.position {
        case .main:
            .leading
        case .sub:
            .trailing
        }
    }

    private var alignment: Alignment {
        switch line.position {
        case .main:
            .leading
        case .sub:
            .trailing
        }
    }

    @ViewBuilder private func additionalContent(for lyrics: TTMLLyrics) -> some View {
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

    private func textRenderer(for lyrics: TTMLLyrics) -> some TextRenderer {
        DisplayLyricsRenderer(elapsedTime: elapsedTime, strings: lyrics.children)
    }
}
