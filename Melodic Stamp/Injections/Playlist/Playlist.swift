//
//  Playlist.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/27.
//

import Collections
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
    var segments: Segments

    private(set) var indexer: TrackIndexer
    private(set) var tracks: [Track] = []

    private(set) var isLoading: Bool = false

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

        Task {
            loadIndexer()
        }

        logger.info("Loaded canonical playlist from \(url)")
    }

    convenience init?(copyingFrom playlist: Playlist) async throws {
        guard playlist.mode.isCanonical else { return nil }

        let playlistID = UUID()
        try FileManager.default.copyItem(at: playlist.possibleURL, to: Self.url(forID: playlistID))

        await self.init(loadingWith: playlistID)
    }

    func makeCanonical() throws {
        // Migrates to a new canonical playlist

        do {
            try FileManager.default.createDirectory(at: possibleURL, withIntermediateDirectories: true)
        } catch {
            return
        }

        mode = .canonical

        var migratedCurrentTrackURL: URL?
        for (index, track) in tracks.enumerated() {
            guard let migratedTrack = try? migrateTrack(from: track) else { continue }
            tracks[index] = migratedTrack

            let wasCurrentTrack = track.url == segments.state.currentTrackURL
            if wasCurrentTrack {
                migratedCurrentTrackURL = migratedTrack.url
            }
        }

        segments.state.currentTrackURL = migratedCurrentTrackURL

        try write()
        try indexTracks(with: captureIndices())
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

    var count: Int {
        indexer.value.count
    }

    var loadedCount: Int {
        tracks.count
    }

    var isEmpty: Bool {
        count == 0
    }

    var isLoaded: Bool {
        loadedCount != 0
    }
}

extension Playlist {
    static func url(forID id: UUID) -> URL {
        URL.playlists.appending(component: id.uuidString, directoryHint: .isDirectory)
    }
}

extension Playlist {
    private func captureIndices() -> TrackIndexer.Value {
        OrderedDictionary(
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

    func loadIndexer() {
        guard mode.isCanonical else { return }
        indexer.value = indexer.read() ?? [:]
    }

    func loadTracks() async {
        guard mode.isCanonical else { return }
        guard !isLoading else { return }
        isLoading = true
        loadIndexer()

        tracks.removeAll()
        for await track in indexer.loadTracks() {
            tracks.append(track)
        }
        isLoading = false
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
    func isExistingCanonicalTrack(at url: URL) -> Bool {
        guard mode.isCanonical else { return false }
        return tracks.contains { $0.url == url }
    }

    private func deleteTrack(at url: URL) throws {
        guard isExistingCanonicalTrack(at: url) else { return }
        if currentTrack?.url == url {
            currentTrack = nil
        }

        Task {
            tracks.removeAll { $0.url == url }
            try FileManager.default.removeItem(at: url)

            logger.info("Deleted canonical track at \(url)")
        }
    }

    private func createFolder() throws {
        try FileManager.default.createDirectory(at: possibleURL, withIntermediateDirectories: true)
    }

    private func generateCanonicalURL(for url: URL) -> URL {
        let trackID = UUID()
        return possibleURL
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)
    }

    private func migrateTrack(from track: Track) throws -> Track {
        try createFolder()

        let destinationURL = generateCanonicalURL(for: track.url)
        try FileManager.default.copyItem(at: track.url, to: destinationURL)

        logger.info("Migrating to canonical track at \(destinationURL), copying from \(track.url)")
        return try Track(
            migratingFrom: track, to: destinationURL,
            useFallbackTitleIfNotProvided: true
        )
    }

    func getTrack(at url: URL) -> Track? {
        first(where: { $0.url == url })
    }

    func createTrack(from url: URL) async -> Track? {
        await withCheckedContinuation { continuation in
            switch mode {
            case .referenced:
                continuation.resume(returning: Track(loadingFrom: url))
            case .canonical:
                var track: Track?
                if let loadedTrack = Track(loadingFrom: url, completion: {
                    guard let track else { return continuation.resume(returning: nil) }
                    continuation.resume(returning: try? self.migrateTrack(from: track))
                }) {
                    track = loadedTrack
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func getOrCreateTrack(at url: URL) async -> Track? {
        if let track = getTrack(at: url) {
            track
        } else {
            await createTrack(from: url)
        }
    }
}

extension Playlist {
    func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        tracks.move(fromOffsets: indices, toOffset: destination)

        try? indexTracks(with: captureIndices())
    }

    func add(_ tracks: [Track], at destination: Int? = nil) {
        let filteredTracks = tracks.filter { !self.tracks.contains($0) }

        if let destination, self.tracks.indices.contains(destination) {
            self.tracks.insert(contentsOf: filteredTracks, at: destination)
        } else {
            self.tracks.append(contentsOf: filteredTracks)
        }

        try? indexTracks(with: captureIndices())
    }

    func remove(_ tracks: [Track]) {
        for track in tracks {
            Task {
                try deleteTrack(at: track.url)
            }
        }

        try? indexTracks(with: captureIndices())
    }

    func clearPlaylist() {
        remove(tracks)
    }
}
