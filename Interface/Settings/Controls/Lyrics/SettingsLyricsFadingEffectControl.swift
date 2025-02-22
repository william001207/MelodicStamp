//
//  SettingsLyricsFadingEffectControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsLyricsFadingEffectControl: View {
    @Default(.isLyricsFadingEffectEnabled) private var isEnabled

    var body: some View {
        Toggle(isOn: $isEnabled) {
            Text("Fading effect")
            Text(LocalizedStringResource(
                "Settings Control (Lyrics Fading Effect): (Subtitle) Fading Effect",
                defaultValue: """
                Applies a fading blur and opacity effect to lyrics that are not currently highlighted.
                """
            ))
        }
    }
}
