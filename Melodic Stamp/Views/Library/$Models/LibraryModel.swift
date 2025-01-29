//
//  LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import SwiftUI

@Observable final class LibraryModel {
    private(set) var playlists: [Playlist] = []
    private var indexer: PlaylistIndexer = .init()

    init() {
        Task {
            try await refresh()
        }
    }
}

extension LibraryModel: Sequence {
    func makeIterator() -> Array<Playlist>.Iterator {
        playlists.makeIterator()
    }

    var isEmpty: Bool {
        playlists.isEmpty
    }

    var count: Int {
        playlists.count
    }
}

extension LibraryModel {
    private func captureIndices() -> PlaylistIndexer.Value {
        playlists.map(\.id)
    }

    private func indexPlaylists(with value: PlaylistIndexer.Value) throws {
        indexer.value = value
        try indexer.write()
    }

    func refresh() async throws {
        indexer.value = indexer.read() ?? []
        await playlists = indexer.loadPlaylists()
    }
}

extension LibraryModel {
    func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)

        try? indexPlaylists(with: captureIndices())
    }

    func add(_ playlists: [Playlist]) {
        for playlist in playlists {
            guard !self.playlists.contains(playlist) else { continue }
            self.playlists.append(playlist)
        }

        try? indexPlaylists(with: captureIndices())
    }

    func remove(_ playlists: [Playlist]) {
        self.playlists.removeAll { playlists.contains($0) }

        try? indexPlaylists(with: captureIndices())
    }
}
