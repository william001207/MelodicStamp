//
//  DelegatedPlaylistStateStorage.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/30.
//

import SwiftUI

struct DelegatedPlaylistStateStorage: View {
    @Environment(PlayerModel.self) private var player

    var body: some View {
        ZStack {
            stateObservations()
        }
    }

    @ViewBuilder private func stateObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistStatus) { _, _ in
                guard player.playlistStatus.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlistStatus.write(segments: [.state])
                }
            }
    }
}
