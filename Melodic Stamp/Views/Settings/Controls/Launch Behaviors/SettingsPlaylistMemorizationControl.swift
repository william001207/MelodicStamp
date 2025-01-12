//
//  SettingsPlaylistMemorizationControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsPlaylistMemorizationControl: View {
    @Default(.memorizesPlaylists) private var memorizesPlaylists
    @Default(.memorizesPlaybackPositions) private var memorizesPlaybackPositions
    @Default(.memorizesPlaybackVolumes) private var memorizesPlaybackVolumes

    var body: some View {
        Toggle(isOn: $memorizesPlaylists) {
            Text("Restores playlists for each window")
        }

        Toggle("Restores playback positions", isOn: $memorizesPlaybackPositions)
            .disabled(!memorizesPlaylists)

        Toggle("Restores playback volumes", isOn: $memorizesPlaybackVolumes)
            .disabled(!memorizesPlaylists)
    }
}
