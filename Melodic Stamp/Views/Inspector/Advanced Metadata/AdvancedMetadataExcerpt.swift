//
//  AdvancedMetadataExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct AdvancedMetadataExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarInspectorTab.advancedMetadata.systemSymbol)
                .frame(height: 64)

            Text("Metadata")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    AdvancedMetadataExcerpt()
}
