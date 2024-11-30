//
//  PlaylistExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct PlaylistExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarTab.playlist.systemSymbol)
                .frame(height: 64)
                .alignmentGuide(ExcerptAlignment.alignment) { d in
                    d[.bottom]
                }
            
            Text("Playlist")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    PlaylistExcerpt()
}
