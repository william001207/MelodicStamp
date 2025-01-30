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
        }
    }

    @ViewBuilder private func infoObservations() -> some View {
        Color.clear
            .onChange(of: player[playlistMetadata: \.info]) { _, _ in
                Task.detached {
                    try await player.playlist.writeMetadata(segments: [.info])
                }
            }
    }

    @ViewBuilder private func stateObservations() -> some View {
        Color.clear
            .onChange(of: player[playlistMetadata: \.state]) { _, _ in
                Task.detached {
                    try await player.playlist.writeMetadata(segments: [.state])
                }
            }
    }
}
