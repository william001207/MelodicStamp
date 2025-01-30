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
            .onChange(of: player.playlistMetadataSegments.info) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.writeMetadata(segments: [.info])
                }
            }
    }

    @ViewBuilder private func stateObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistMetadataSegments.state) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.writeMetadata(segments: [.state])
                }
            }
    }

    @ViewBuilder private func artworkObservations() -> some View {
        Color.clear
            .onChange(of: player.playlistMetadataSegments.artwork) { _, _ in
                guard player.playlist.mode.isCanonical else { return }
                Task.detached {
                    try await player.playlist.writeMetadata(segments: [.artwork])
                }
            }
    }
}
