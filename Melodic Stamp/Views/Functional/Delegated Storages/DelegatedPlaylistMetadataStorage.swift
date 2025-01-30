//
//  DelegatedPlaylistMetadataStorage.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/30.
//

import SwiftUI

struct DelegatedPlaylistMetadataStorage: View {
    @Environment(PlayerModel.self) private var player

    var body: some View {
        ZStack {
            infoObservations()
            stateObservations()
            artworkObservations()
        }
    }

    @ViewBuilder private func infoObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistSegments.info) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.write(segments: [.info])
                }
            }
    }

    @ViewBuilder private func stateObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistSegments.state) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.write(segments: [.state])
                }
            }
    }

    @ViewBuilder private func artworkObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistSegments.artwork) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.write(segments: [.artwork])
                }
            }
    }
}
