//
//  SettingsBehaviorsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsBehaviorsPage: View {
    var body: some View {
        SettingsExcerptView(
            .launchBehaviors,
            descriptionKey: "Control \(Bundle.main[localized: .displayName])'s behaviors."
        )

        Section {
            SettingsDefaultPlaybackModeControl()

            SettingsAsksForPlaylistInformationControl()
        }
    }
}

#Preview {
    Form {
        SettingsBehaviorsPage()
    }
    .formStyle(.grouped)
}
