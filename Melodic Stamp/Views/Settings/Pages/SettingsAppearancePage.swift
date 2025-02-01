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
        SettingsExcerptView(
            .appearance,
            descriptionKey: "Decorate \(Bundle.main[localized: .displayName]) as you like."
        )

        Section {
            SettingsDynamicTitleBarControl()

            SettingsMotionLevelControl()
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
