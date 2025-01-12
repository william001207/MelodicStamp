//
//  SettingsSidebarIcon.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SFSafeSymbols
import SwiftUI

struct SettingsSidebarIcon: View {
    var systemSymbol: SFSymbol
    var color: Color

    init(_ systemSymbol: SFSymbol, color: Color = .accent) {
        self.systemSymbol = systemSymbol
        self.color = color
    }

    init(_ tab: SettingsTab) {
        self.init(tab.systemSymbol, color: tab.color)
    }

    var body: some View {
        Image(systemSymbol: systemSymbol)
            .foregroundStyle(.white)
            .frame(width: 16, height: 16)
            .padding(2)
            .gradientBackground(color)
            .clipShape(.rect(cornerRadius: 5))
    }
}

#Preview {
    SettingsSidebarIcon(.appearance)
}
