//
//  MetadataExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct MetadataExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarTab.metadata.systemSymbol)
                .frame(height: 64)
                .alignmentGuide(ExcerptAlignment.alignment) { d in
                    d[.bottom]
                }
            
            Text("Metadata")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    MetadataExcerpt()
}
