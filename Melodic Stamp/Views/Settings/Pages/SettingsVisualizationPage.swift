//
//  SettingsVisualizationPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct SettingsVisualizationPage: View {
    var body: some View {
        LazyVStack {
            Section {
                VStack {
                    SettingsView.bannerIcon(.waveform, color: .pink)

                    Text("Visualization")
                        .font(.title)

                    Text("This is a sample description.")
                        .foregroundStyle(.secondary)
                }
                .padding(7)
            }
        }
    }
}

#Preview {
    Form {
        SettingsVisualizationPage()
    }
    .formStyle(.grouped)
}
