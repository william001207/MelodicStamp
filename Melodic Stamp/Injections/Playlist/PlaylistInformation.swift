//
//  PlaylistInformation.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Defaults
import SwiftUI

extension PlaylistInformation {
    enum FileSegment: String, CaseIterable {
        case info = ".info"
        case state = ".state"
        case artwork = ".artwork"

        func url(relativeTo root: URL) -> URL {
            root.appending(path: rawValue)
        }
    }

    struct State: Equatable, Hashable, Codable {
        var currentTrackURL: URL?
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

extension PlaylistInformation: TypeNameReflectable {}

struct PlaylistInformation: Equatable, Hashable, Identifiable, Codable {
    let id: UUID

    var info: Info
    var state: State
    var artwork: Artwork

    private init(id: UUID, info: Info, state: State, artwork: Artwork) {
        self.id = id
        self.info = info
        self.state = state
        self.artwork = artwork
    }

    init(readingFromPlaylistID id: UUID) throws {
        let url = Self.url(forID: id)
        self.id = id
        self.info = try JSONDecoder().decode(Info.self, from: Self.read(segment: .info, fromDirectory: url))
        self.state = try JSONDecoder().decode(State.self, from: Self.read(segment: .state, fromDirectory: url))
        self.artwork = try JSONDecoder().decode(Artwork.self, from: Self.read(segment: .artwork, fromDirectory: url))

        logger.info("Successfully read playlist information for playlist at \(url)")
        dump(self)
    }
}

extension PlaylistInformation {
    static func blank(bindingTo id: UUID = .init()) -> Self {
        .init(id: id, info: .init(), state: .init(), artwork: .init())
    }

    static func url(forID id: UUID) -> URL {
        URL.playlists.appending(component: id.uuidString, directoryHint: .isDirectory)
    }

    var url: URL {
        Self.url(forID: id)
    }

    func write(segments: [FileSegment]) throws {
        guard !segments.isEmpty else { return }

        for segment in segments {
            let data = switch segment {
            case .info:
                try JSONEncoder().encode(info)
            case .state:
                try JSONEncoder().encode(state)
            case .artwork:
                try JSONEncoder().encode(artwork)
            }
            try Self.write(segment: segment, ofData: data, toDirectory: url)
        }

        logger.info("Successfully wrote playlist information segments \(segments) for playlist at \(url)")
    }
}

private extension PlaylistInformation {
    static func read(segment: FileSegment, fromDirectory root: URL) throws -> Data {
        let url = segment.url(relativeTo: root)
        return try Data(contentsOf: url)
    }

    static func write(segment: FileSegment, ofData fileData: Data, toDirectory root: URL) throws {
        let url = segment.url(relativeTo: root)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try fileData.write(to: url)
    }
}
