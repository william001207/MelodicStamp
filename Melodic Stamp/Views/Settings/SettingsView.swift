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
    @State private var isSidebarVisible: Bool = false

    var body: some View {
        AppKitNavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    switch tab {
                    case .general:
                        HStack {
                            Image(systemSymbol: .gear)
                            Text("General")
                        }
                        .tag(tab)
                    case .visualization:
                        HStack {
                            Image(systemSymbol: .waveform)
                            Text("Visualization")
                        }
                        .tag(tab)
                    }
                }
            }
            .listStyle(SidebarListStyle())
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
        .ignoresSafeArea(.all)
        .toolbar {
            // Preserves the titlebar style
            Color.clear
        }
    }
}

#Preview {
    SettingsView()
}
