//
//  SettingsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Morphed
import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    NavigationLink(value: tab) {
                        switch tab {
                        case .general:
                            Image(systemSymbol: .gear)
                            Text("General")
                        case .visualization:
                            Image(systemSymbol: .waveform)
                            Text("Visualization")
                        }
                    }
                }
            }
        } detail: {
            Form {
                switch selectedTab {
                case .general:
                    SettingsGeneralPage()
                        .navigationTitle(Text("General"))
                case .visualization:
                    SettingsVisualizationPage()
                        .navigationTitle(Text("Visualization"))
                }
            }
            .formStyle(.grouped)
        }
        .background(MakeTitledWindow())
    }
}

#Preview {
    SettingsView()
}
