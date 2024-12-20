//
//  TTMLLyricsView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Luminare
import SwiftUI

struct TTMLLyricsView: View {
    var lyrics: TTMLLyrics

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(lyrics.children, id: \.beginTime) { lyric in
                            Group {
                                Text(lyric.text)
                                    .modifier(LuminareHoverable())
                                    .luminareBordered(false)
                                    .luminareHorizontalPadding(0)
                                    .luminareMinHeight(24)

                                ForEach(0 ..< lyric.trailingSpaceCount, id: \.self) { _ in
                                    Text(" ")
                                }
                            }
                            .bold()
                        }
                    }
                    .padding(.horizontal, 4)
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))

            if let translation = lyrics.translation {
                HStack {
                    Image(systemSymbol: .translate)
                        .padding(2)
                        .frame(
                            width: 16, height: 16
                        )

                    Text("\(translation)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .foregroundStyle(.tint)
            }

            if let roman = lyrics.roman {
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
}

#Preview {
    TTMLLyricsView(lyrics: .init())
}
