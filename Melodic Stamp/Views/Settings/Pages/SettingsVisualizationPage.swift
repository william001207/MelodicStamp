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
            descriptionKey: "Tweak \(Bundle.main.displayName)'s audio visualization experience to the fullest."
        )

        Section {
            SettingsGradientDynamicsControl()
        }
    }
}

#Preview {
    Form {
        SettingsVisualizationPage()
    }
    .formStyle(.grouped)
}
