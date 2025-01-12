//
//  SettingsLaunchBehaviorsPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsLaunchBehaviorsPage: View {
    var body: some View {
        SettingsExcerptView(.launchBehaviors, descriptionKey: "Launch behaviors settings excerpt.")

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
