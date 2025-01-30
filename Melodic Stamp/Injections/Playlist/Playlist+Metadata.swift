//
//  Playlist+Metadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Defaults
import SwiftUI

extension Playlist.Metadata: TypeNameReflectable {}

extension Playlist.Metadata {
    enum Segment: String, CaseIterable {
        case info = ".info"
        case state = ".state"
        case artwork = ".artwork"

        func url(relativeTo root: URL) -> URL {
            root.appending(path: rawValue, directoryHint: .notDirectory)
        }
    }

    struct State: Equatable, Hashable, Codable {
        var currentTrackURL: URL?
        var currentTrackElapsedTime: TimeInterval = .zero
        var playbackMode: PlaybackMode = Defaults[.defaultPlaybackMode]
        var playbackLooping: Bool = false
    }

    struct Info: Equatable, Hashable, Codable {
        var title: String = ""
        var description: String = ""
    }

    struct Artwork: Equatable, Hashable, Codable {
        var tiffRepresentation: Data?

        var image: NSImage? {
            guard let tiffRepresentation else { return nil }
            return NSImage(data: tiffRepresentation)
        }
    }
}

extension Playlist.Metadata {
    struct Segments: Equatable, Hashable, Codable {
        var info: Info = .init()
        var state: State = .init()
        var artwork: Artwork = .init()
    }
}

extension Playlist {
    struct Metadata: Equatable, Hashable, Identifiable, Codable {
        let id: UUID
        var segments: Segments

        private init(id: UUID, segments: Segments) {
            self.id = id
            self.segments = segments
        }

        init(readingFromPlaylistID id: UUID) async throws {
            let url = Self.url(forID: id)
            self.id = id

            let info = try await JSONDecoder().decode(Info.self, from: Self.read(segment: .info, fromDirectory: url))
            let state = try await JSONDecoder().decode(State.self, from: Self.read(segment: .state, fromDirectory: url))
            let artwork = try await JSONDecoder().decode(Artwork.self, from: Self.read(segment: .artwork, fromDirectory: url))
            self.segments = .init(info: info, state: state, artwork: artwork)

            logger.info("Successfully read playlist metadata for playlist at \(url)")

            #if DEBUG
                dump(self)
            #endif
        }
    }
}

extension Playlist.Metadata {
    static func blank(bindingTo id: UUID = .init()) -> Self {
        .init(id: id, segments: .init())
    }

    static func url(forID id: UUID) -> URL {
        URL.playlists.appending(component: id.uuidString, directoryHint: .isDirectory)
    }

    var url: URL {
        Self.url(forID: id)
    }

    func write(segments: [Segment] = Segment.allCases) throws {
        guard !segments.isEmpty else { return }

        for segment in segments {
            let data = switch segment {
            case .info:
                try JSONEncoder().encode(self.segments.info)
            case .state:
                try JSONEncoder().encode(self.segments.state)
            case .artwork:
                try JSONEncoder().encode(self.segments.artwork)
            }
            try Self.write(segment: segment, ofData: data, toDirectory: url)
        }

        logger.info("Successfully written playlist metadata segments \(segments) for playlist at \(url)")
    }
}

private extension Playlist.Metadata {
    static func read(segment: Segment, fromDirectory root: URL) async throws -> Data {
        let url = segment.url(relativeTo: root)
        return try Data(contentsOf: url)
    }

    static func write(segment: Segment, ofData fileData: Data, toDirectory root: URL) throws {
        let url = segment.url(relativeTo: root)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try fileData.write(to: url)
    }
}
