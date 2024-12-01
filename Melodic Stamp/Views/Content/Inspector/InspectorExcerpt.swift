//
//  InspectorExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct InspectorExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarTab.inspector.systemSymbol)
                .frame(height: 64)
                .alignmentGuide(ExcerptAlignment.alignment) { d in
                    d[.bottom]
                }

            Text("Inspector")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    InspectorExcerpt()
}
