//
//  TTMLInspectorLyricsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/15.
//

import Luminare
import SFSafeSymbols
import SwiftUI

struct TTMLInspectorLyricsView: View {
    var isHighlighted: Bool = false
    var lyrics: TTMLLyrics

    var body: some View {
        Group {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(lyrics.children, id: \.self) { lyric in
                        Group {
                            Text(lyric.text)
                                .modifier(LuminareHoverable())
                                .luminareBordered(false)
                                .luminareHorizontalPadding(0)
                                .luminareMinHeight(24)

                            ForEach(0 ..< lyric.trailingSpaceCount, id: \.self) { _ in
                                Text(verbatim: " ")
                            }
                        }
                        .bold()
                    }
                }
                .padding(.horizontal, 8)
                .foregroundStyle(.tint)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.tint.quinary)
        .clipShape(.rect(cornerRadius: 8))
        .tint(isHighlighted ? .accent : .primary)

        VStack(alignment: .leading, spacing: 2) {
            ForEach(lyrics.translations, id: \.locale) { translation in
                TTMLInspectorInformationView(systemSymbol: .translate) {
                    HStack(spacing: 2) {
                        if let symbol = translation.locale.localize(systemSymbol: .character) {
                            Image(systemSymbol: symbol)
                        }

                        Text(translation.locale.identifier)
                    }
                    .foregroundStyle(.secondary)

                    Text(translation.text)
                }
                .foregroundStyle(.tint)
            }

            if let roman = lyrics.roman {
                TTMLInspectorInformationView(systemSymbol: .characterPhonetic) {
                    Text(roman)
                }
                .foregroundStyle(.purple)
            }
        }
    }
}

#Preview {
    TTMLInspectorLyricsView(isHighlighted: false, lyrics: .init(
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
    ))
}
