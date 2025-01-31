//
//  Playlist+Status.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/31.
//

import SwiftUI

extension Playlist {
    @MainActor struct Status: Hashable, Identifiable {
        private var playlist: Playlist

        init(wrapping playlist: Playlist) {
            self.playlist = playlist
        }
    }
}

extension Playlist.Status {
    nonisolated var id: UUID { playlist.id }
    var mode: Playlist.Mode { playlist.mode }
    var tracks: [Track] { playlist.tracks }

    var url: URL { playlist.url }
    var unwrappedURL: URL? { playlist.unwrappedURL }
    var canMakeCanonical: Bool { playlist.canMakeCanonical }

    var count: Int { playlist.count }
    var loadedCount: Int { playlist.loadedCount }
    var isEmpty: Bool { playlist.isEmpty }
    var isLoaded: Bool { playlist.isLoaded }
    var isLoading: Bool { playlist.isLoading }

    var segments: Playlist.Segments {
        get { playlist.segments }
        nonmutating set { playlist.segments = newValue }
    }

    var segmentsBinding: Binding<Playlist.Segments> {
        Binding {
            segments
        } set: { newValue in
            segments = newValue
        }
    }

    func write(segments: [Playlist.Segment] = Playlist.Segment.allCases) throws {
        try playlist.write(segments: segments)
    }
}

extension Playlist.Status: @preconcurrency Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist.Status: @preconcurrency Sequence {
    func makeIterator() -> Array<Track>.Iterator {
        playlist.makeIterator()
    }
}
