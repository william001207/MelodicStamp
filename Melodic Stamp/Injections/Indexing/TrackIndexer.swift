//
//  TrackIndexer.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

struct TrackIndexer: Indexer {
    let playlistID: UUID
    var folderURL: URL {
        .playlists.appending(path: playlistID.uuidString, directoryHint: .isDirectory)
    }

    // The keys are the file names, while the values are the path extensions
    var value: [UUID: String] = [:]
}

extension TrackIndexer {
    func trackURL(for element: Value.Element) -> URL {
        folderURL
            .appending(path: element.key.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(element.value)
    }

    func loadTracks() async -> [Track] {
        guard !value.isEmpty else { return [] }

        var tracks: [Track] = []
        for element in value {
            guard let track = await Track(loadingFrom: trackURL(for: element)) else { continue }
            tracks.append(track)
        }
        return tracks
    }
}
