//
//  SettingsDefaultPlaybackModeControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsDefaultPlaybackModeControl: View {
    @Default(.defaultPlaybackMode) private var defaultPlaybackMode

    var body: some View {
        Picker("Default playback mode", selection: $defaultPlaybackMode) {
            ForEach(PlaybackMode.allCases) { mode in
                PlaybackModeView(mode: mode)
            }
        }
    }
}
