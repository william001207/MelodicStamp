//
//  AnalysisExcerpt.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

struct AnalysisExcerpt: View {
    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: SidebarInspectorTab.analysis.systemSymbol)
                .frame(height: 64)

            Text("Analysis")
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
    }
}

#Preview {
    AdvancedMetadataExcerpt()
}
