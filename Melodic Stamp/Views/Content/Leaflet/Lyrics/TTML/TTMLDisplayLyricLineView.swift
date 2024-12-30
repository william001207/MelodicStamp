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

    var inactiveOpacity: Double = 0.55
    var highlightReleasingDelay: TimeInterval = 0.25

    @State private var isActive: Bool = false
    @State private var backgroundContentSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                // It's a must to avoid view hierarchies from being reconstructed
                // This is causing surprisingly low impact on performance, so use it
                activeContent()
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .opacity(isActive ? 1 : 0)

                inactiveContent()
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .opacity(isActive ? 0 : 1)
            }

            // Shows background lyrics when necessary (has background lyrics && lyrics is active)
            if !line.backgroundLyrics.isEmpty {
                // Avoid using conditional content, instead, shrink this view to affect layout
                Color.clear
                    .frame(height: isActive ? backgroundContentSize.height : 0)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: alignment) {
                        backgroundContent()
                            .blur(radius: isActive ? 0 : 8)
                            .scaleEffect(isActive ? 1 : 0.8, anchor: .bottom)
                            .opacity(isActive ? 1 : 0)
                            .onGeometryChange(for: CGSize.self) { proxy in
                                proxy.size
                            } action: { newValue in
                                backgroundContentSize = newValue
                            }
                    }
            }
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(textAlignment)
        .frame(maxWidth: .infinity, alignment: alignment)
        .animation(.linear, value: elapsedTime) // For text rendering
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
