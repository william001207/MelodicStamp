//
//  SettingsDynamicTitleBarControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsDynamicTitleBarControl: View {
    @Default(.dynamicTitleBar) var dynamicTitleBar

    var body: some View {
        Picker(selection: $dynamicTitleBar) {
            ForEach(Defaults.DynamicTitleBar.allCases) { mode in
                switch mode {
                case .never: Text("Never")
                case .always: Text("Always")
                case .whilePlaying: Text("While playing")
                }
            }
        } label: {
            Text("Dynamic title bar")
            Text("Displays the information of the currently playing track as window title.")
        }
    }
}
