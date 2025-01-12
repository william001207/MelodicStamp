//
//  SettingsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Morphed
import SFSafeSymbols
import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general
    @State private var isSidebarVisible: Bool = false

    var body: some View {
        AppKitNavigationSplitView {
            List(selection: $selectedTab) {
                Section {
                    entry(.general)
                }

                Section {
                    entry(.visualization)
                    entry(.lyrics)
                }

                Section {
                    entry(.performance)
                }
            }
            .listStyle(.sidebar)
        } detail: {
            Form {
                Group {
                    switch selectedTab {
                    case .general:
                        SettingsGeneralPage()
                    case .visualization:
                        SettingsVisualizationPage()
                    case .lyrics:
                        SettingsLyricsPage()
                    case .performance:
                        SettingsPerformancePage()
                    }
                }
                .navigationTitle(Text(selectedTab.name))
            }
            .formStyle(.grouped)
        }
        .frame(width: 712)
        .frame(minHeight: 500, idealHeight: 778)
        .ignoresSafeArea(.all)
        .toolbar {
            // Preserves the titleBar style
            Color.clear
        }
        .background(MakeCustomizable(customization: { window in
            window.toolbarStyle = .unified
            window.titlebarAppearsTransparent = false
            window.titlebarSeparatorStyle = .automatic
        }))
    }

    @ViewBuilder private func entry(_ tab: SettingsTab) -> some View {
        HStack {
            SettingsSidebarIcon(tab)
            Text(tab.name)
        }
        .tag(tab)
    }
}

#Preview {
    SettingsView()
}
