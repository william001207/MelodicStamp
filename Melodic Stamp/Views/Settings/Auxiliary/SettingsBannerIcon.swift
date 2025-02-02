//
//  SettingsBannerIcon.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SFSafeSymbols
import SwiftUI

struct SettingsBannerIcon: View {
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
            .font(.system(size: 42))
            .frame(width: 50, height: 50)
            .padding(6)
            .simpleGradient(color)
            .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    SettingsBannerIcon(.appearance)
}
