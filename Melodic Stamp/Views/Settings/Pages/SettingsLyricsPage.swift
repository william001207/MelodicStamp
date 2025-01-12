//
//  SettingsLyricsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsLyricsPage: View {
    var body: some View {
        LazyVStack {
            Section {
                SettingsExcerptView(.lyrics, descriptionKey: "Lyrics settings excerpt.")
            }
        }
    }
}

#Preview {
    Form {
        SettingsLyricsPage()
    }
    .formStyle(.grouped)
}
