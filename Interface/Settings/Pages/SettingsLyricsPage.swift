//
//  SettingsLyricsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsLyricsPage: View {
    var body: some View {
        SettingsExcerptView(
            .lyrics,
            descriptionKey: "Customize how lyrics are displayed in the leaflet page."
        )

        Section {
            SettingsLyricsFadingEffectControl()

            SettingsLyricsMaxWidthControl()
        }

        Section {
            SettingsLyricsAttachmentsControl()
        } header: {
            Text("Attachments & Type Size")
            Text(LocalizedStringResource(
                "Settings Page (Lyrics): (Subtitle) Attachments & Type Size",
                defaultValue: """
                While type size can be adjusted independently in the leaflet page, all changes of the below properties including type size will cause a reset in the lyrics view in order to obtain a correct visual effect.
                """
            ))
        }

        Section {
            SettingsLyricsTypeSizeControl()
        }
    }
}

#Preview {
    Form {
        SettingsLyricsPage()
    }
    .formStyle(.grouped)
}
