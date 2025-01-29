//
//  PlaylistIndex.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

extension PlaylistIndex: TypeNameReflectable {}

struct PlaylistIndex: Equatable, Hashable, Codable {
    static let fileName: String = ".index"
    static let url: URL = .playlists.appending(path: Self.fileName, directoryHint: .notDirectory)

    var playlistIDs: [UUID]

    static func read() -> Self {
        guard
            let data = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(Self.self, from: data)
        else { return .init(playlistIDs: []) }
        return result
    }

    func write() throws {
        try FileManager.default.createDirectory(at: .playlists, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(self)
        try data.write(to: Self.url)
    }
}

extension PlaylistIndex {
    func loadPlaylists() async -> [Playlist] {
        guard !playlistIDs.isEmpty else { return [] }

        var playlists: [Playlist] = []
        for id in playlistIDs {
            guard let playlist = await Playlist(loadingWith: id) else { continue }
            playlists.append(playlist)
        }
        return playlists
    }

    mutating func updateIDs(from playlists: [Playlist]) {
        playlistIDs = playlists.map(\.information.id)
    }
}
