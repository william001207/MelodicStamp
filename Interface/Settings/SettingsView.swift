//
//  SettingsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SFSafeSymbols
import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .appearance
    @State private var isSidebarVisible: Bool = false

    var body: some View {
        AppKitNavigationSplitView {
            List(selection: $selectedTab) {
                Section {
                    entry(.appearance)
                    entry(.visualization)
                    entry(.lyrics)
                }

                Section {
                    entry(.launchBehaviors)
                    entry(.performance)
                }

                Section {
                    entry(.feedback)
                }
            }
            .listStyle(.sidebar)
        } detail: {
            Form {
                Group {
                    switch selectedTab {
                    case .appearance:
                        SettingsAppearancePage()
                    case .visualization:
                        SettingsVisualizationPage()
                    case .lyrics:
                        SettingsLyricsPage()
                    case .launchBehaviors:
                        SettingsBehaviorsPage()
                    case .performance:
                        SettingsPerformancePage()
                    case .feedback:
                        SettingsFeedbackPage()
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
            // Preserves title bar style
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
