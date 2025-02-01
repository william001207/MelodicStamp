//
//  SettingsBackgroundStylesControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsBackgroundStylesControl: View {
    @Default(.mainWindowBackgroundStyle) private var mainWindow
    @Default(.miniPlayerBackgroundStyle) private var miniPlayer

    var body: some View {
        Picker("Main window", selection: $mainWindow) {
            ForEach(Defaults.MainWindowBackgroundStyle.allCases) { style in
                switch style {
                case .opaque: Text("Opaque")
                case .vibrant: Text("Vibrant")
                case .ethereal: Text("Ethereal")
                }
            }
        }

        Picker("Mini player", selection: $miniPlayer) {
            ForEach(Defaults.MiniPlayerBackgroundStyle.allCases) { style in
                switch style {
                case .opaque: Text("Opaque")
                case .vibrant: Text("Vibrant")
                case .ethereal: Text("Ethereal")
                case .chroma: Text("Chroma")
                }
            }
        }
    }
}
