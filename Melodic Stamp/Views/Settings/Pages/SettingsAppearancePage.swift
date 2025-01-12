//
//  SettingsAppearancePage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Defaults
import SwiftUI

struct SettingsAppearancePage: View {
    var body: some View {
        SettingsExcerptView(.appearance, descriptionKey: "Appearance settings excerpt.")

        Section {
            SettingsDynamicTitleBarControl()
        }

        Section("Background Styles") {
            SettingsBackgroundStylesControl()
        }
    }
}

#Preview {
    Form {
        SettingsAppearancePage()
    }
    .formStyle(.grouped)
}
