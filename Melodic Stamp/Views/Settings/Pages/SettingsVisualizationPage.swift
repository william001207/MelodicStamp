//
//  SettingsVisualizationPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct SettingsVisualizationPage: View {
    var body: some View {
        SettingsExcerptView(.visualization, descriptionKey: "Visualization settings excerpt.")
    }
}

#Preview {
    Form {
        SettingsVisualizationPage()
    }
    .formStyle(.grouped)
}
