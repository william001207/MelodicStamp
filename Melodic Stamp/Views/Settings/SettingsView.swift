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
        TabView(selection: $selectedTab) {
            TabSection {
                Tab(value: SettingsTab.general) {
                    wrapped {
                        SettingsGeneralPage()
                    }
                } label: {
                    Text("General")
                    Image(systemSymbol: .gear)
                }

                Tab(value: SettingsTab.visualization) {
                    wrapped {
                        SettingsVisualizationPage()
                    }
                } label: {
                    Text("Visualization")
                    Image(systemSymbol: .waveform)
                }
            }
        }
        // Like the System Settings
        .frame(minWidth: 715, maxWidth: 715, minHeight: 470, maxHeight: .infinity)
    }

    @ViewBuilder private func wrapped(@ViewBuilder content: () -> some View) -> some View {
        Form {
            content()
        }
        .formStyle(.grouped)
        .overlay(alignment: .top) {
            VisualEffectView(material: .headerView, blendingMode: .withinWindow)
                .overlay(alignment: .bottom) {
                    VStack {
                        Divider()
                    }
                }
                .frame(height: 92)
                .ignoresSafeArea()
        }
        .safeAreaPadding(.top, 48)
    }
}

#Preview {
    SettingsView()
}
