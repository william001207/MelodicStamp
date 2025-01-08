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

    @State private var searchText: String = ""

    var body: some View {
        AppKitNavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    switch tab {
                    case .general:
                        HStack {
                            Self.sidebarIcon(.gear, color: .gray)
                            Text("General")
                        }
                        .tag(tab)
                    case .visualization:
                        HStack {
                            Self.sidebarIcon(.waveform, color: .pink)
                            Text("Visualization")
                        }
                        .tag(tab)
                    }
                }
            }
            .listStyle(.sidebar)
            .searchable(text: $searchText)
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

    @ViewBuilder static func sidebarIcon(_ symbol: SFSymbol, color: Color) -> some View {
        Image(systemSymbol: symbol)
            .colorScheme(.dark)
            .frame(width: 16, height: 16)
            .padding(2)
            .gradientBackground(color)
            .clipShape(.rect(cornerRadius: 5))
    }

    @ViewBuilder static func bannerIcon(_ symbol: SFSymbol, color: Color) -> some View {
        Image(systemSymbol: symbol)
            .colorScheme(.dark)
            .font(.system(size: 42))
            .frame(width: 50, height: 50)
            .padding(6)
            .gradientBackground(color)
            .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    SettingsView()
}
