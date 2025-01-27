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

    var tracks: [Track] = []
    var currentTrack: Track?

    var playbackMode: PlaybackMode
    var playbackLooping: Bool

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

    init(
        loadingFrom _: URL
    ) {
        self.mode = .canonical
        // TODO:
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
    mutating func play(track: Track) {
        add(urls: [track.url])
        currentTrack = track
    }

    mutating func play(url: URL) async {
        if let track = await Track(url: url) {
            play(track: track)
        }
    }

    mutating func add(urls: [URL]) {
        for url in urls {
            guard !playlist.contains(where: { $0.url == url }) else { continue }

            Task {
                if let track = await Track(url: url) {
                    addToPlaylist(tracks: [track])
                }
            }
        }
    }

    mutating func add(tracks: [Track]) {
        for track in tracks {
            guard !playlist.contains(track) else { continue }
            playlist.append(track)
        }
    }

    mutating func remove(urls: [URL]) {
        for url in urls {
            if let index = playlist.firstIndex(where: { $0.url == url }) {
                if track?.url == url {
                    player.stop()
                    track = nil
                }
                let removed = playlist.remove(at: index)
                selectedTracks.remove(removed)
            }
        }
    }

    mutating func remove(tracks: [Track]) {
        removeFromPlaylist(urls: tracks.map(\.url))
    }

    mutating func removeAll() {
        removeFromPlaylist(tracks: playlist)
    }
}
