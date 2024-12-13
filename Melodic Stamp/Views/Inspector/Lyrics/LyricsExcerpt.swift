//
//  LyricsExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

struct LyricsExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarInspectorTab.lyrics.systemSymbol)
                .frame(height: 64)

            Text("Lyrics")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    AdvancedMetadataExcerpt()
}
