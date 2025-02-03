//
//  SettingsVisualizationPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct SettingsVisualizationPage: View {
    var body: some View {
        SettingsExcerptView(
            .visualization,
            descriptionKey: "Tweak \(Bundle.main[localized: .displayName])'s audio visualization experience to the fullest."
        )

        Section {
            SettingsGradientDynamicsControl()
        }

        Section {
            SettingsGradientFPSControl()

            SettingsGradientResolutionControl()
        }
    }
}

#Preview {
    Form {
        SettingsVisualizationPage()
    }
    .formStyle(.grouped)
}
