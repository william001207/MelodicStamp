//
//  Playlist.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/27.
//

import Defaults
import Foundation

extension Playlist {
    enum Mode {
        case referenced
        case canonical
    }
}

struct Playlist: Equatable, Hashable, Identifiable {
    let id: UUID
    var mode: Mode

    private(set) var tracks: [Track] = []
    private(set) var currentTrack: Track?

    private(set) var playbackMode: PlaybackMode
    private(set) var playbackLooping: Bool

    private init(
        id: UUID,
        mode: Mode,
        playbackMode: PlaybackMode,
        playbackLooping: Bool
    ) {
        self.id = id
        self.mode = mode
        self.playbackMode = playbackMode
        self.playbackLooping = playbackLooping
    }

    init?(indexedBy id: UUID) async {
        self.id = id
        self.mode = .canonical

        let url = URL.playlists.appending(component: id.uuidString)
        guard url.hasDirectoryPath else { return nil }

        // TODO: Read the properties
        self.playbackMode = .loop
        self.playbackLooping = false

        let urls = FileHelper.flatten(contentsOfFolder: url, allowedContentTypes: Array(allowedContentTypes), isRecursive: false)
        for url in urls {
            guard let track = await Track(loadingFrom: url) else { continue }
            tracks.append(track)
        }
    }

    init?(makingPermanent oldValue: Playlist) async {
        self.id = oldValue.id
        self.mode = .canonical
        self.playbackMode = oldValue.playbackMode
        self.playbackLooping = oldValue.playbackLooping

        let url = URL.playlists.appending(component: id.uuidString)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        for track in oldValue.tracks {
            guard let permanentTrack = await getOrCreateTrack(at: track.url) else { continue }
            tracks.append(permanentTrack)
        }
    }

    static func referenced() -> Playlist {
        .init(
            id: UUID(),
            mode: .referenced,
            playbackMode: Defaults[.defaultPlaybackMode],
            playbackLooping: false
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
        switch playbackMode {
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
        switch playbackMode {
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
        }
    }

    private func createTrack(copyingFrom url: URL) async throws -> Track? {
        let trackID = UUID()
        let playlistURL = URL.playlists.appending(component: id.uuidString)
        try FileManager.default.createDirectory(at: playlistURL, withIntermediateDirectories: true)

        let destinationURL = playlistURL
            .appending(component: trackID.uuidString, directoryHint: .notDirectory)
            .appendingPathExtension(url.pathExtension)

        try FileManager.default.copyItem(at: url, to: destinationURL)
        return await Track(loadingFrom: destinationURL)
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
    mutating func setCurrentTrack(_ track: Track?) {
        currentTrack = track
    }

    mutating func setPlaybackMode(_ mode: PlaybackMode) {
        playbackMode = mode
    }

    mutating func setPlaybackLooping(_ isEnabled: Bool) {
        playbackLooping = isEnabled
    }

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
