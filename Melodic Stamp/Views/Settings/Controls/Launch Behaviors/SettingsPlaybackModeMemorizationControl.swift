//
//  SettingsPlaybackModeMemorizationControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsPlaybackModeMemorizationControl: View {
    @Default(.memorizesPlaybackModes) private var memorizesPlaybackModes
    @Default(.defaultPlaybackMode) private var defaultPlaybackMode

    var body: some View {
        Toggle(isOn: $memorizesPlaybackModes) {
            Text("Restores playback modes for each window")
        }

        Picker("Default playback mode", selection: $defaultPlaybackMode) {
            ForEach(PlaybackMode.allCases) { mode in
                PlaybackModeView(mode: mode)
            }
        }
    }
}
