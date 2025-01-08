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
            .listStyle(.sidebar)
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
        .frame(width: 712)
        .frame(minHeight: 500, idealHeight: 778)
        .ignoresSafeArea(.all)
        .toolbar {
            // Preserves the titlebar style
            Color.clear
        }
        .background(MakeCustomizable { window in
            window.toolbarStyle = .unified
            window.titlebarAppearsTransparent = false
            window.titlebarSeparatorStyle = .automatic
        })
    }
}

#Preview {
    SettingsView()
}
