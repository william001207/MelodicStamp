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

@Observable class Playlist: Identifiable {
    private(set) var mode: Mode
    private var metadata: Playlist.Metadata
    private var indexer: TrackIndexer

    private(set) var tracks: [Track] = []
    var currentTrack: Track? {
        get { first { $0.url == metadata.state.currentTrackURL } }
        set { metadata.state.currentTrackURL = newValue?.url }
    }

    var id: UUID {
        metadata.id
    }

    var possibleURL: URL {
        metadata.url
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
        mode: Mode,
        metadata: Playlist.Metadata
    ) {
        self.mode = mode
        self.metadata = metadata
        self.indexer = .init(playlistID: metadata.id)
    }

    convenience init?(loadingWith id: UUID) async {
        guard let metadata = try? await Playlist.Metadata(readingFromPlaylistID: id) else { return nil }
        self.init(mode: .canonical, metadata: metadata)

        logger.info("Loaded canonical playlist from \(metadata.url)")
    }

    func makeCanonical() async {
        guard !mode.isCanonical else { return }
        // Migrates to a new canonical playlist

        let url = metadata.url

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            try metadata.write(segments: Playlist.Metadata.Segment.allCases)
        } catch {
            return
        }

        mode = .canonical

        var migratedTracks: [Track] = []
        var migratedCurrentTrackURL: URL?
        for track in tracks {
            guard let migratedTrack = try? await migrateTrack(from: track) else { continue }
            migratedTracks.append(migratedTrack)

            let wasCurrentTrack = track.url == metadata.state.currentTrackURL
            if wasCurrentTrack {
                migratedCurrentTrackURL = migratedTrack.url
            }
        }

        metadata.state.currentTrackURL = migratedCurrentTrackURL
        clearPlaylist()
        add(migratedTracks)

        logger.info("Successfully made canonical playlist at \(url)")
    }

    static func referenced(bindingTo id: UUID = .init()) -> Playlist {
        .init(
            mode: .referenced,
            metadata: .blank(bindingTo: id)
        )
    }
}

extension Playlist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mode)
        hasher.combine(metadata)
        hasher.combine(tracks)
    }
}

extension Playlist: Equatable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist: Sequence {
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
    subscript<V>(metadata keyPath: WritableKeyPath<Metadata, V>) -> V {
        get { metadata[keyPath: keyPath] }
        set { metadata[keyPath: keyPath] = newValue }
    }

    func writeMetadata(segments: [Metadata.Segment] = Metadata.Segment.allCases) throws {
        try metadata.write(segments: segments)
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
        switch metadata.state.playbackMode {
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
        switch metadata.state.playbackMode {
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
        try FileManager.default.createDirectory(at: metadata.url, withIntermediateDirectories: true)
    }

    private func generateCanonicalURL(for url: URL) -> URL {
        guard !Self.isCanonical(url: url) else { return url }
        let trackID = UUID()
        return metadata.url
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)
    }

    private func migrateTrack(from track: Track) async throws -> Track {
        try createFolder()

        let destinationURL = generateCanonicalURL(for: track.url)
        try FileManager.default.copyItem(at: track.url, to: destinationURL)

        logger.info("Migrating to canonical track at \(destinationURL), copying from \(track.url)")
        return try await Track(
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
