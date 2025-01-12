//
//  SettingsGeneralPlaybackModeMemorizationControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsGeneralPlaybackModeMemorizationControl: View {
    @Default(.memorizesPlaybackModes) private var memorizesPlaybackModes
    @Default(.defaultPlaybackMode) private var defaultPlaybackMode
    
    var body: some View {
        Toggle(isOn: $memorizesPlaybackModes) {
            Text("Memorizes playback modes")
            Text("Restores playback modes for each window after launch.")
        }
        
        Picker("Default playback mode", selection: $defaultPlaybackMode) {
            ForEach(PlaybackMode.allCases) { mode in
                PlaybackModeView(mode: mode)
            }
        }
    }
}
