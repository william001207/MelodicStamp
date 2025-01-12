//
//  SettingsGeneralPlaylistMemorizationControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsGeneralPlaylistMemorizationControl: View {
    @Default(.memorizesPlaylists) private var memorizesPlaylists
    @Default(.memorizesPlaybackPositions) private var memorizesPlaybackPositions
    @Default(.memorizesPlaybackVolumes) private var memorizesPlaybackVolumes

    var body: some View {
        Toggle(isOn: $memorizesPlaylists) {
            Text("Memorizes playlists")
            Text("Restores playlists for each window after launch.")
        }

        Toggle("Memorizes playback positions", isOn: $memorizesPlaybackPositions)
            .disabled(!memorizesPlaylists)

        Toggle("Memorizes playback volumes", isOn: $memorizesPlaybackVolumes)
            .disabled(!memorizesPlaylists)
    }
}
