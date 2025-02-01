//
//  SettingsPerformancePage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsPerformancePage: View {
    var body: some View {
        SettingsExcerptView(
            .performance,
            descriptionKey: "Adjust \(Bundle.main[localized: .displayName])'s performance to meet your hardware's needs."
        )

        Section {
            SettingsMotionLevelControl()
        }

        Section("Gradient") {
            SettingsGradientFPSControl()

            SettingsGradientResolutionControl()
        }
    }
}

#Preview {
    Form {
        SettingsPerformancePage()
    }
    .formStyle(.grouped)
}
