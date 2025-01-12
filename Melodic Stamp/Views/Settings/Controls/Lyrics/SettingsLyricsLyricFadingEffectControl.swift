//
//  SettingsLyricsLyricFadingEffectControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsLyricsLyricFadingEffectControl: View {
    @Default(.isLyricsFadingEffectEnabled) private var isEnabled

    var body: some View {
        Toggle(isOn: $isEnabled) {
            Text("Fading effect")
            Text("Applies a fading blur and opacity effect to lyrics that are not currently highlighted.")
        }
    }
}
