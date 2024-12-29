//
//  TTMLDisplayLyricLineView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

// import Luminare
import SwiftUI

struct TTMLDisplayLyricLineView: View {
    var line: TTMLLyricLine
    var elapsedTime: TimeInterval
    var isHighlighted: Bool = false
    var isNearlyHighlighted: Bool = false
    
    var inactiveOpacity: Double = 0.55
    var highlightDelay: TimeInterval = 0.25

    @State private var isActive: Bool = false

    var body: some View {
        ZStack {
            // It's a must to avoid view hierarchies from being reconstructed
            // This is causing surprisingly low impact on performance, so use it
            activeContent()
                .opacity(isActive ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: alignment)

            inactiveContent()
                .frame(maxWidth: .infinity, alignment: alignment)
                .opacity(isActive ? 0 : 1)
        }
        .multilineTextAlignment(textAlignment)
        .frame(maxWidth: .infinity, alignment: alignment)
        // Isolating switching animation between renderers
        .onChange(of: isHighlighted, initial: true) { _, newValue in
            if !newValue {
                withAnimation(.smooth(duration: 0.25).delay(highlightDelay)) {
                    isActive = false
                }
            } else {
                withAnimation(.smooth(duration: 0.1)) {
                    isActive = true
                }
            }
        }
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

    @ViewBuilder private func activeContent() -> some View {
        let hasBackgroundLyrics = !line.backgroundLyrics.isEmpty
        let lyricsRenderer = textRenderer(for: line.lyrics)
        let backgroundLyricsRenderer = textRenderer(for: line.backgroundLyrics)

        VStack(alignment: alignment.horizontal, spacing: 5) {
            Text(stringContent(of: line.lyrics))
                .font(.title)
                .bold()
                .textRenderer(lyricsRenderer)

            additionalContent(for: line.lyrics)
                .font(.title3)

            if hasBackgroundLyrics {
                Group {
                    Text(stringContent(of: line.backgroundLyrics))
                        .font(.title2)
                        .bold()
                        .textRenderer(backgroundLyricsRenderer)

                    additionalContent(for: line.backgroundLyrics)
                        .font(.title3)
                }
                .transition(.blurReplace)
            }
        }
    }

    @ViewBuilder private func inactiveContent() -> some View {
        let hasBackgroundLyrics = !line.backgroundLyrics.isEmpty

        VStack(alignment: alignment.horizontal, spacing: 5) {
            Text(stringContent(of: line.lyrics))
                .font(.title)
                .bold()
                .opacity(inactiveOpacity)

            additionalContent(for: line.lyrics)
                .font(.title3)
                .opacity(inactiveOpacity)

            if hasBackgroundLyrics {
                Group {
                    Text(stringContent(of: line.backgroundLyrics))
                        .font(.title2)
                        .bold()
                        .opacity(inactiveOpacity)

                    additionalContent(for: line.backgroundLyrics)
                        .font(.title3)
                        .opacity(inactiveOpacity)
                }
                .transition(.blurReplace)
            }
        }
    }

    @ViewBuilder private func additionalContent(for lyrics: TTMLLyrics)
        -> some View
    {
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
        DisplayLyricsRenderer(
            elapsedTime: elapsedTime, strings: lyrics.children,
            inactiveOpacity: inactiveOpacity
        )
    }
}
