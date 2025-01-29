//
//  PlaylistIndexer.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

struct PlaylistIndexer: Indexer {
    var folderURL: URL { .playlists }

    var value: [UUID] = []
}

extension PlaylistIndexer {
    func loadPlaylists() async -> [Playlist] {
        guard !value.isEmpty else { return [] }

        var playlists: [Playlist] = []
        for id in value {
            guard let playlist = await Playlist(loadingWith: id) else { continue }
            playlists.append(playlist)
        }
        return playlists
    }
}
