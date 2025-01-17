//
//  SettingsHidesLyricsWhileInactiveControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Defaults
import SwiftUI

struct SettingsHidesLyricsWhileInactiveControl: View {
    @Default(.hidesLyricsWhileInactive) var isEnabled

    var body: some View {
        Toggle("Stops rendering lyrics", isOn: $isEnabled)
    }
}
