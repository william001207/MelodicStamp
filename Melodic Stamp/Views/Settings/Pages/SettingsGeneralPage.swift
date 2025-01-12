//
//  SettingsGeneralPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Defaults
import SwiftUI

struct SettingsGeneralPage: View {
    var body: some View {
        SettingsExcerptView(.general, descriptionKey: "General settings excerpt.")

        Section("Appearance") {
            SettingsGeneralDynamicTitleBarControl()
        }

        Section("Launch Behaviors") {
            SettingsGeneralPlaybackModeMemorizationControl()
        }

        Section {
            SettingsGeneralPlaylistMemorizationControl()
        }
    }
}

#Preview {
    Form {
        SettingsGeneralPage()
    }
    .formStyle(.grouped)
}
