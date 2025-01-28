//
//  Playlist.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/27.
//

import Defaults
import Foundation

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

extension Playlist: TypeNameReflectable {}

struct Playlist: Equatable, Hashable, Identifiable {
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

    init?(indexedBy id: UUID) async {
        self.mode = .canonical

        guard let information = try? PlaylistInformation(readingFromPlaylistID: id) else { return nil }
        self.information = information

        let urls = FileHelper.flatten(contentsOfFolder: information.url, allowedContentTypes: Array(allowedContentTypes), isRecursive: false)
        for url in urls {
            guard let track = await Track(loadingFrom: url) else { return }
            tracks.append(track)
        }
    }

    init?(makingPermanent oldValue: Playlist) async {
        self.mode = .canonical
        self.information = oldValue.information

        let url = information.url
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            try information.write(segments: PlaylistInformation.FileSegment.allCases)
        } catch {
            return nil
        }

        for track in oldValue.tracks {
            guard let permanentTrack = await getOrCreateTrack(at: track.url) else { return }
            tracks.append(permanentTrack)
        }

        logger.info("Successfully made permanent playlist at \(url)")
    }

    static func referenced() -> Playlist {
        .init(
            mode: .referenced,
            information: .blank()
        )
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

    private func generateCanonicalURL(for url: URL) -> URL {
        guard !Self.isCanonical(url: url) else { return url }
        let trackID = UUID()
        return information.url
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)
    }

    private func createTrack(copyingFrom url: URL) async throws -> Track? {
        try FileManager.default.createDirectory(at: information.url, withIntermediateDirectories: true)

        let destinationURL = generateCanonicalURL(for: url)
        try FileManager.default.copyItem(at: url, to: destinationURL)

        logger.info("Created canonical track at \(destinationURL), copying from \(url)")
        return await Track(loadingFrom: destinationURL)
    }

    func getTrack(at url: URL) async -> Track? {
        first(where: { $0.url == url })
    }

    func getOrCreateTrack(at url: URL) async -> Track? {
        if let track = await getTrack(at: url) {
            if Self.isCanonical(url: url) {
                track
            } else {
                await Track(migratingFrom: track, withURL: generateCanonicalURL(for: url), useFallbackTitleIfNotProvided: true)
            }
        } else {
            switch mode {
            case .referenced:
                await Track(loadingFrom: url)
            case .canonical:
                if Self.isCanonical(url: url) {
                    await Track(loadingFrom: url)
                } else {
                    try? await createTrack(copyingFrom: url)
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

    mutating func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        tracks.move(fromOffsets: indices, toOffset: destination)
    }
}
