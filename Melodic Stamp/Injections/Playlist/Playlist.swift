//
//  Playlist.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/27.
//

import Defaults
import Foundation

extension Playlist: TypeNameReflectable {}

extension Playlist {
    enum Mode: String, Equatable, Hashable, CaseIterable, Identifiable, Codable {
        case referenced
        case canonical

        var id: Self { self }

        var isCanonical: Bool {
            switch self {
            case .canonical:
                true
            default:
                false
            }
        }
    }
}

struct Playlist: Hashable, Identifiable {
    var mode: Mode
    var information: PlaylistInformation

    private(set) var tracks: [Track] = []
    var currentTrack: Track? {
        get {
            first { $0.url == information.state.currentTrackURL }
        }

        set {
            information.state.currentTrackURL = newValue?.url
        }
    }

    var id: UUID {
        information.id
    }

    private init(
        mode: Mode,
        information: PlaylistInformation
    ) {
        self.mode = mode
        self.information = information
    }

    init?(loadingWith id: UUID) async {
        self.mode = .canonical

        guard let information = try? await PlaylistInformation(readingFromPlaylistID: id) else { return nil }
        self.information = information
    }

    init?(makingCanonical oldValue: Playlist) async {
        let url = oldValue.information.url
        if FileManager.default.fileExists(atPath: url.path) {
            // Load from existing canonical playlist

            guard let instance = await Self(loadingWith: oldValue.id) else { return nil }
            self = instance

            await loadTracks()

            logger.info("Loaded canonical playlist from \(url)")
        } else {
            // Copy and create a new canonical playlist

            self.mode = .canonical
            self.information = oldValue.information

            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                try await information.write(segments: PlaylistInformation.Segment.allCases)
            } catch {
                return nil
            }

            for track in oldValue.tracks {
                guard let migratedTrack = try? await migrateTrack(from: track) else { continue }
                tracks.append(migratedTrack)

                let wasCurrentTrack = track.url == oldValue.information.state.currentTrackURL
                if wasCurrentTrack {
                    information.state.currentTrackURL = migratedTrack.url
                }
            }

            logger.info("Successfully made canonical playlist at \(url)")
        }
    }

    static func referenced(bindingTo id: UUID = .init()) -> Playlist {
        .init(
            mode: .referenced,
            information: .blank(bindingTo: id)
        )
    }

    mutating func loadTracks() async {
        tracks.removeAll()
        let urls = FileHelper.flatten(contentsOf: information.url, isRecursive: false)
        for url in urls {
            guard let track = await Track(loadingFrom: url) else { return }
            tracks.append(track)
        }
    }
}

extension Playlist: Equatable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist: Sequence, RandomAccessCollection {
    typealias Index = Array<Track>.Index

    func makeIterator() -> Array<Track>.Iterator {
        tracks.makeIterator()
    }

    subscript(position: Array<Track>.Index) -> Track {
        _read {
            yield tracks[position]
        }
    }

    var startIndex: Array<Track>.Index {
        tracks.startIndex
    }

    var endIndex: Array<Track>.Index {
        tracks.endIndex
    }

    mutating func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        tracks.move(fromOffsets: indices, toOffset: destination)
    }
}

extension Playlist {
    var nextTrack: Track? {
        guard let nextIndex else { return nil }
        return self[nextIndex]
    }

    var previousTrack: Track? {
        guard let previousIndex else { return nil }
        return self[previousIndex]
    }

    var hasCurrentTrack: Bool {
        currentTrack != nil
    }

    var hasNextTrack: Bool {
        nextTrack != nil
    }

    var hasPreviousTrack: Bool {
        previousTrack != nil
    }

    private var index: Int? {
        guard let currentTrack else { return nil }
        return firstIndex(of: currentTrack)
    }

    private var nextIndex: Int? {
        switch information.state.playbackMode {
        case .sequential:
            guard let index else { return nil }
            let nextIndex = index + 1

            guard nextIndex < endIndex else { return nil }
            return nextIndex
        case .loop:
            guard let index else { return nil }
            return (index + 1) % count
        case .shuffle:
            return randomIndex()
        }
    }

    private var previousIndex: Int? {
        switch information.state.playbackMode {
        case .sequential:
            guard let index else { return nil }
            let previousIndex = index - 1

            guard previousIndex >= 0 else { return nil }
            return previousIndex
        case .loop:
            guard let index else { return nil }
            return (index + count - 1) % count
        case .shuffle:
            return randomIndex()
        }
    }

    func randomIndex() -> Int? {
        guard !isEmpty else { return nil }

        if let currentTrack, let index = firstIndex(of: currentTrack) {
            let indices = Array(indices).filter { $0 != index }
            return indices.randomElement()
        } else {
            return indices.randomElement()
        }
    }
}

extension Playlist {
    static func isCanonical(url: URL) -> Bool {
        let parent = URL.playlists.standardized
        return url.standardized.path().hasPrefix(parent.path())
    }

    private static func deleteTrack(at url: URL) throws {
        guard isCanonical(url: url) else { return }
        Task {
            try FileManager.default.removeItem(at: url)

            logger.info("Deleted canonical track at \(url)")
        }
    }

    private func createFolder() throws {
        try FileManager.default.createDirectory(at: information.url, withIntermediateDirectories: true)
    }

    private func generateCanonicalURL(for url: URL) -> URL {
        guard !Self.isCanonical(url: url) else { return url }
        let trackID = UUID()
        return information.url
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)
    }

    private func migrateTrack(from track: Track) async throws -> Track {
        try createFolder()

        let destinationURL = generateCanonicalURL(for: track.url)
        try FileManager.default.copyItem(at: track.url, to: destinationURL)

        logger.info("Migrating to canonical track at \(destinationURL), copying from \(track.url)")
        return await Track(
            migratingFrom: track, to: destinationURL,
            useFallbackTitleIfNotProvided: true
        )
    }

    func getTrack(at url: URL) async -> Track? {
        first(where: { $0.url == url })
    }

    func getOrCreateTrack(at url: URL) async -> Track? {
        if let track = await getTrack(at: url) {
            track
        } else {
            switch mode {
            case .referenced:
                await Track(loadingFrom: url)
            case .canonical:
                if let track = await Track(loadingFrom: url) {
                    try? await migrateTrack(from: track)
                } else {
                    nil
                }
            }
        }
    }
}

extension Playlist {
    mutating func add(_ tracks: [Track]) {
        for track in tracks {
            guard !contains(track) else { return }
            self.tracks.append(track)
        }
    }

    mutating func remove(_ tracks: [Track]) {
        if let currentTrack, tracks.contains(currentTrack) {
            self.currentTrack = nil
        }

        for track in tracks {
            self.tracks.removeAll { $0 == track }
            try? Self.deleteTrack(at: track.url)
        }
    }

    mutating func clearPlaylist() {
        remove(tracks)
    }
}
