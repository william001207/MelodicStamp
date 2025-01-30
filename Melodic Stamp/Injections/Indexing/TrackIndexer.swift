//
//  TrackIndexer.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Collections
import Foundation

struct TrackIndexer: Indexer {
    let playlistID: UUID
    var folderURL: URL {
        .playlists.appending(path: playlistID.uuidString, directoryHint: .isDirectory)
    }

    // The keys are the file names, while the values are the path extensions
    var value: OrderedDictionary<UUID, String> = [:]
}

extension TrackIndexer {
    func trackURL(for element: Value.Element) -> URL {
        folderURL
            .appending(path: element.key.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(element.value)
    }

    func loadTracks() -> AsyncStream<Track> {
        .init { continuation in
            guard !value.isEmpty else { return continuation.finish() }

            Task {
                for element in value {
                    guard let track = await Track(loadingFrom: trackURL(for: element)) else { return }
                    continuation.yield(track)
                }

                continuation.finish()
            }
        }
    }
}
