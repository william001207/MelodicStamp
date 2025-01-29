//
//  LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import SwiftUI

@MainActor @Observable final class LibraryModel {
    private(set) var playlists: [Playlist] = []
    private var index: PlaylistIndex!

    init() {
        Task {
            await refresh()
        }
    }

    var hasPlaylists: Bool { !playlists.isEmpty }
}

extension LibraryModel {
    private func updatePlaylistIndex(with ids: [UUID]) async throws {
        guard var index else { return }
        index.playlistIDs = ids
        try await index.write()
    }

    func refresh() async {
        await index = .read()
        await playlists = index.loadPlaylists()
    }
}

extension LibraryModel {
    func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)

        let ids = playlists.map(\.id)
        Task {
            try await self.updatePlaylistIndex(with: ids)
        }
    }

    func add(_ playlists: [Playlist]) {
        self.playlists.append(contentsOf: playlists)

        let ids = playlists.map(\.id)
        Task {
            try await self.updatePlaylistIndex(with: ids)
        }
    }

    func remove(_ playlists: [Playlist]) {
        self.playlists.removeAll { playlists.contains($0) }

        let ids = playlists.map(\.id)
        Task {
            try await self.updatePlaylistIndex(with: ids)
        }
    }
}
