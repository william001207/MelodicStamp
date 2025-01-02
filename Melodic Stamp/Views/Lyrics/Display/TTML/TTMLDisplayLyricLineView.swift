//
//  TTMLDisplayLyricLineView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

// import Luminare
import SwiftUI

struct TTMLDisplayLyricLineView: View {
    var line: TTMLLyricLine
    var elapsedTime: TimeInterval
    var isHighlighted: Bool = false

    var inactiveOpacity: Double = 0.55
    var highlightReleasingDelay: TimeInterval = 0.25

    @State private var isActive: Bool = false

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                if isActive {
                    activeContent()
                        .frame(maxWidth: .infinity, alignment: alignment)
                } else {
                    inactiveContent()
                        .frame(maxWidth: .infinity, alignment: alignment)
                }
            }

            // Shows background lyrics when necessary
            if isActive, !line.backgroundLyrics.isEmpty {
                backgroundContent()
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .transition(.blurReplace)
            }
        }
        .multilineTextAlignment(textAlignment)
        .frame(maxWidth: .infinity, alignment: alignment)
        .onChange(of: isHighlighted, initial: true) { _, newValue in
            if !newValue {
                withAnimation(.smooth(duration: 0.25).delay(highlightReleasingDelay)) {
                    isActive = false
                }
            } else {
                withAnimation(.smooth(duration: 0.1)) {
                    isActive = true
                }
            }
        }
        .animation(.linear, value: elapsedTime) // For time interpolation
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
        let lyricsRenderer = textRenderer(for: line.lyrics)

        VStack(alignment: alignment.horizontal, spacing: 5) {
            Text(stringContent(of: line.lyrics))
                .font(.title)
                .bold()
                .textRenderer(lyricsRenderer)

            additionalContent(for: line.lyrics)
                .font(.title3)
                .opacity(0.75)
        }
    }

    @ViewBuilder private func inactiveContent() -> some View {
        VStack(alignment: alignment.horizontal, spacing: 5) {
            Text(stringContent(of: line.lyrics))
                .font(.title)
                .bold()
                .opacity(inactiveOpacity)

            additionalContent(for: line.lyrics)
                .font(.title3)
                .opacity(inactiveOpacity)
        }
    }

    @ViewBuilder private func backgroundContent() -> some View {
        let backgroundLyricsRenderer = textRenderer(for: line.backgroundLyrics)

        VStack(alignment: alignment.horizontal, spacing: 5) {
            Text(stringContent(of: line.backgroundLyrics))
                .font(.title2)
                .bold()
                .textRenderer(backgroundLyricsRenderer)

            additionalContent(for: line.backgroundLyrics)
                .font(.title3)
                .opacity(0.75)
        }
    }

    @ViewBuilder private func additionalContent(for lyrics: TTMLLyrics)
        -> some View {
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
            elapsedTime: elapsedTime,
            strings: lyrics.children, vowels: lyrics.vowels,
            inactiveOpacity: inactiveOpacity
        )
    }
}
