//
//  SettingsLaunchBehaviorsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsLaunchBehaviorsPage: View {
    var body: some View {
        SettingsExcerptView(
            .launchBehaviors,
            descriptionKey: "Control what \(Bundle.main[localized: .displayName]) should do when launching from a previous interruption."
        )

        Section {
            SettingsPlaybackModeMemorizationControl()
        }

        Section {
            SettingsPlaylistMemorizationControl()
        }
    }
}

#Preview {
    Form {
        SettingsLaunchBehaviorsPage()
    }
    .formStyle(.grouped)
}
