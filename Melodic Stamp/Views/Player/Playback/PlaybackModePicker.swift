//
//  PlaybackModePicker.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/6.
//

import SwiftUI

struct PlaybackModePicker: View {
    var modes: [PlaybackMode] = PlaybackMode.allCases
    @Binding var selection: PlaybackMode

    var body: some View {
        let name = PlaybackModeView.name(of: selection)

        Picker(name, selection: $selection) {
            ForEach(modes) { mode in
                PlaybackModeView(mode: mode)
            }
        }
    }
}
