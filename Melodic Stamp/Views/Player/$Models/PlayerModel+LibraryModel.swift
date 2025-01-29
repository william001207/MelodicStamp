//
//  PlayerModel+LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

extension PlayerModel {
    @Observable final class LibraryModel {
        private var index: PlaylistIndex!

        private(set) var playlists: [Playlist] = []
        var playlist: Playlist

        init(bindingTo id: UUID) {
            self.playlist = .referenced(bindingTo: id)

            Task.detached {
                await self.index = .read()
            }
        }
    }
}

extension PlayerModel.LibraryModel {
    var hasPlaylists: Bool { !playlists.isEmpty }
}

extension PlayerModel.LibraryModel {
    private func updatePlaylistIndex(with ids: [UUID]) async throws {
        guard var index else { return }
        index.playlistIDs = ids
        try await index.write()
    }

    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)

        let ids = playlists.map(\.information.id)
        Task.detached {
            try await self.updatePlaylistIndex(with: ids)
        }
    }

    func saveOrLoadPlaylist() async {
        guard
            !playlist.mode.isCanonical,
            var canonicalPlaylist = await Playlist(makingCanonical: playlist)
        else { return }
        await canonicalPlaylist.loadTracks()
        playlist = canonicalPlaylist

        if !playlists.contains(canonicalPlaylist) {
            playlists.append(canonicalPlaylist)

            let ids = playlists.map(\.information.id)
            Task.detached {
                try await self.updatePlaylistIndex(with: ids)
            }
        }
    }

    func refresh() async {
        await index = .read()
        await playlists = index.loadPlaylists()
    }
}
