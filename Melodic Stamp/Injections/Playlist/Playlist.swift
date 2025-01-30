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

@MainActor @Observable class Playlist: Identifiable {
    nonisolated let id: UUID
    private(set) var mode: Mode
    private var indexer: TrackIndexer
    var segments: Segments

    private(set) var tracks: [Track] = []

    // Delegated variables
    // Must not have inlined getters and setters, otherwise causing UI glitches

    var currentTrack: Track? {
        didSet {
            Task {
                segments.state.currentTrackURL = currentTrack?.url
            }
        }
    }

    private func loadDelegatedVariables() {
        currentTrack = tracks.first { $0.url == segments.state.currentTrackURL }
    }

    var possibleURL: URL {
        Self.url(forID: id)
    }

    var canonicalURL: URL? {
        switch mode {
        case .referenced:
            nil
        case .canonical:
            possibleURL
        }
    }

    private init(
        id: UUID,
        mode: Mode,
        segments: Segments
    ) {
        self.id = id
        self.mode = mode
        self.segments = segments
        self.indexer = .init(playlistID: id)
        loadDelegatedVariables()
    }

    convenience init?(loadingWith id: UUID) async {
        let url = Self.url(forID: id)
        guard let segments = try? await Segments(loadingFrom: url) else { return nil }
        self.init(id: id, mode: .canonical, segments: segments)

        logger.info("Loaded canonical playlist from \(url)")
    }

    func makeCanonical() async {
        // Migrates to a new canonical playlist

        do {
            try FileManager.default.createDirectory(at: possibleURL, withIntermediateDirectories: true)
            try write(segments: Segment.allCases)
        } catch {
            return
        }

        mode = .canonical

        var migratedTracks: [Track] = []
        var migratedCurrentTrackURL: URL?
        for track in tracks {
            guard let migratedTrack = try? await migrateTrack(from: track) else { continue }
            migratedTracks.append(migratedTrack)

            let wasCurrentTrack = track.url == segments.state.currentTrackURL
            if wasCurrentTrack {
                migratedCurrentTrackURL = migratedTrack.url
            }
        }

        segments.state.currentTrackURL = migratedCurrentTrackURL
        clearPlaylist()
        add(migratedTracks)
        loadDelegatedVariables()

        logger.info("Successfully made canonical playlist at \(self.possibleURL)")
    }

    static func referenced(bindingTo id: UUID = .init()) -> Playlist {
        .init(
            id: id,
            mode: .referenced,
            segments: .init()
        )
    }
}

extension Playlist: @preconcurrency Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mode)
        hasher.combine(tracks)
    }
}

extension Playlist: @preconcurrency Equatable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist: @preconcurrency Sequence {
    func makeIterator() -> Array<Track>.Iterator {
        tracks.makeIterator()
    }

    var isEmpty: Bool {
        tracks.isEmpty
    }

    var count: Int {
        tracks.count
    }
}

extension Playlist {
    static func url(forID id: UUID) -> URL {
        URL.playlists.appending(component: id.uuidString, directoryHint: .isDirectory)
    }
}

extension Playlist {
    private func captureIndices() -> TrackIndexer.Value {
        Dictionary(
            uniqueKeysWithValues: tracks
                .map(\.url)
                .compactMap { url in
                    guard let id = UUID(uuidString: url.deletingPathExtension().lastPathComponent) else { return nil }
                    return (id, url.pathExtension)
                }
        )
    }

    private func indexTracks(with value: TrackIndexer.Value) throws {
        guard mode.isCanonical else { return }
        indexer.value = value
        try indexer.write()
    }

    func refresh() async {
        guard mode.isCanonical else { return }
        indexer.value = indexer.read() ?? [:]
        await tracks = indexer.loadTracks()
    }
}

extension Playlist {
    func write(segments: [Playlist.Segment] = Playlist.Segment.allCases) throws {
        guard !segments.isEmpty, let url = canonicalURL else { return }

        for segment in segments {
            let data = switch segment {
            case .info:
                try JSONEncoder().encode(self.segments.info)
            case .state:
                try JSONEncoder().encode(self.segments.state)
            case .artwork:
                try JSONEncoder().encode(self.segments.artwork)
            }
            try Segments.write(segment: segment, ofData: data, toDirectory: url)
        }

        logger.info("Successfully written playlist metadata segments \(segments) for playlist at \(url)")
    }
}

extension Playlist {
    var nextTrack: Track? {
        guard let nextIndex else { return nil }
        return tracks[nextIndex]
    }

    var previousTrack: Track? {
        guard let previousIndex else { return nil }
        return tracks[previousIndex]
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

    private var currentIndex: Int? {
        guard let currentTrack else { return nil }
        return tracks.firstIndex(of: currentTrack)
    }

    private var nextIndex: Int? {
        switch segments.state.playbackMode {
        case .sequential:
            guard let currentIndex else { return nil }
            let nextIndex = currentIndex + 1

            guard nextIndex < tracks.endIndex else { return nil }
            return nextIndex
        case .loop:
            guard let currentIndex else { return nil }
            return (currentIndex + 1) % tracks.count
        case .shuffle:
            return randomIndex()
        }
    }

    private var previousIndex: Int? {
        switch segments.state.playbackMode {
        case .sequential:
            guard let currentIndex else { return nil }
            let previousIndex = currentIndex - 1

            guard previousIndex >= 0 else { return nil }
            return previousIndex
        case .loop:
            guard let currentIndex else { return nil }
            return (currentIndex + tracks.count - 1) % tracks.count
        case .shuffle:
            return randomIndex()
        }
    }

    func randomIndex() -> Int? {
        guard !tracks.isEmpty else { return nil }

        if let currentTrack, let index = tracks.firstIndex(of: currentTrack) {
            let indices = Array(tracks.indices).filter { $0 != index }
            return indices.randomElement()
        } else {
            return tracks.indices.randomElement()
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
        try FileManager.default.createDirectory(at: possibleURL, withIntermediateDirectories: true)
    }

    private func generateCanonicalURL(for url: URL) -> URL {
        guard !Self.isCanonical(url: url) else { return url }
        let trackID = UUID()
        return possibleURL
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)
    }

    private func migrateTrack(from track: Track) async throws -> Track {
        try createFolder()

        let destinationURL = generateCanonicalURL(for: track.url)
        try FileManager.default.copyItem(at: track.url, to: destinationURL)

        logger.info("Migrating to canonical track at \(destinationURL), copying from \(track.url)")
        return try Track(
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
    func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        tracks.move(fromOffsets: indices, toOffset: destination)

        try? indexTracks(with: captureIndices())
    }

    func add(_ tracks: [Track]) {
        for track in tracks {
            guard !contains(track) else { return }
            self.tracks.append(track)
        }

        try? indexTracks(with: captureIndices())
    }

    func remove(_ tracks: [Track]) {
        if let currentTrack, tracks.contains(currentTrack) {
            self.currentTrack = nil
        }

        for track in tracks {
            self.tracks.removeAll { $0 == track }
            try? Self.deleteTrack(at: track.url)
        }

        try? indexTracks(with: captureIndices())
    }

    func clearPlaylist() {
        remove(tracks)
    }
}
