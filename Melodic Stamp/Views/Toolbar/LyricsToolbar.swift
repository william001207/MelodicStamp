//
//  LyricsToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import SwiftUI

struct LyricsToolbar: View {
    @Binding var lyricsType: LyricsType

    var body: some View {
        Picker(selection: $lyricsType) {
            label(of: .raw)
                .tag(LyricsType.raw)

            Divider()

            label(of: .lrc)
                .tag(LyricsType.lrc)

            label(of: .ttml)
                .tag(LyricsType.ttml)
        } label: {
            ToolbarLabel {
                label(of: lyricsType)
            }
        }
    }

    @ViewBuilder private func label(of type: LyricsType) -> some View {
        switch type {
        case .raw:
            Text("Unprocessed")
        case .lrc:
            Text("Lyrics (.lrc)")
        case .ttml:
            Text("Timed Text (.ttml)")
        }
    }
}
