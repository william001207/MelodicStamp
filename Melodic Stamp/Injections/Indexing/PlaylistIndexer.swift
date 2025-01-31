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
    func loadPlaylists(into playlists: inout [Playlist]) async {
        playlists.removeAll()
        guard !value.isEmpty else { return }

        for element in value {
            guard let playlist = Playlist(loadingWith: element) else { continue }
            playlists.append(playlist)
        }
    }
}
