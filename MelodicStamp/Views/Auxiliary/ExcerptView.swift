//
//  ExcerptView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/26.
//

import SFSafeSymbols
import SwiftUI

struct ExcerptView: View {
    var systemSymbol: SFSymbol
    var title: String

    init(systemSymbol: SFSymbol, title: String) {
        self.systemSymbol = systemSymbol
        self.title = title
    }

    init(tab: some SidebarTab) {
        self.init(systemSymbol: tab.systemSymbol, title: tab.title)
    }

    var body: some View {
        VStack {
            EmptyMusicNoteView(systemSymbol: systemSymbol)
                .frame(height: 64)

            Text(title)
                .font(.title3)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ExcerptView(tab: SidebarInspectorTab.commonMetadata)
}
