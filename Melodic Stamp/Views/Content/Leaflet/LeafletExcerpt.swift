//
//  LeafletExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/13.
//

import SwiftUI

struct LeafletExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarContentTab.leaflet.systemSymbol)
                .frame(height: 64)

            Text("Leaflet")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    LeafletExcerpt()
}
