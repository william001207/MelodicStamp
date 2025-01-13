//
//  SettingsLyricsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsLyricsPage: View {
    var body: some View {
        SettingsExcerptView(.lyrics, descriptionKey: "Lyrics settings excerpt.")

        Section {
            SettingsLyricFadingEffectControl()
        }

        Section {
            SettingsLyricAttachmentsControl()
        } header: {
            Text("Attachments")
            Text("""
            The default visibility of components attached to lyric lines.
            Each can also be configured independently for every window in the leaflet page.
            """)
        }

        Section {
            SettingsLyricTypeSizeControl()
        }
    }
}

#Preview {
    Form {
        SettingsLyricsPage()
    }
    .formStyle(.grouped)
}
