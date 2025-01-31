//
//  PlaylistModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/31.
//

import SwiftUI

@Observable final class PlaylistModel {
    #if DEBUG
        var playlist: Playlist
    #else
        private var playlist: Playlist
    #endif
    private weak var library: LibraryModel?

    init(bindingTo id: UUID = .init(), library: LibraryModel) {
        self.playlist = .referenced(bindingTo: id)
        self.library = library
    }
}

extension PlaylistModel {
    var id: UUID { playlist.id }
    var mode: Playlist.Mode { playlist.mode }
    var tracks: [Track] { playlist.tracks }

    var url: URL { playlist.url }
    var unwrappedURL: URL? { playlist.unwrappedURL }

    var currentTrack: Track? {
        get { playlist.currentTrack }
        set { playlist.currentTrack = newValue }
    }

    var nextTrack: Track? { playlist.nextTrack }
    var previousTrack: Track? { playlist.previousTrack }

    var hasCurrentTrack: Bool { playlist.hasCurrentTrack }
    var hasNextTrack: Bool { playlist.hasNextTrack }
    var hasPreviousTrack: Bool { playlist.hasPreviousTrack }

    var count: Int { playlist.count }
    var loadedCount: Int { playlist.loadedCount }
    var isEmpty: Bool { playlist.isEmpty }
    var isLoaded: Bool { playlist.isLoaded }
    var isLoading: Bool { playlist.isLoading }

    var canMakeCanonical: Bool { playlist.canMakeCanonical }
}

extension PlaylistModel: Equatable {
    static func == (lhs: PlaylistModel, rhs: PlaylistModel) -> Bool {
        lhs.playlist == rhs.playlist
    }
}

extension PlaylistModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(playlist)
    }
}

extension PlaylistModel: Sequence {
    func makeIterator() -> Playlist.Iterator {
        playlist.makeIterator()
    }

    func move(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlist.move(fromOffsets: indices, toOffset: destination)
    }
}

extension PlaylistModel {
    var segments: Playlist.Segments {
        get { playlist.segments }
        set { playlist.segments = newValue }
    }

    var playbackMode: PlaybackMode {
        get { segments.state.playbackMode }
        set { segments.state.playbackMode = newValue }
    }

    var playbackLooping: Bool {
        get { segments.state.playbackLooping }
        set { segments.state.playbackLooping = newValue }
    }
}

extension PlaylistModel {
    func isUnderlying(playlist: Playlist) -> Bool {
        self.playlist == playlist
    }

    func bindTo(_ id: UUID, mode: Playlist.Mode = .referenced) async {
        guard !playlist.mode.isCanonical else { return }
        if mode.isCanonical, let playlist = await Playlist(loadingWith: id) {
            self.playlist = playlist
        } else {
            playlist = .referenced(bindingTo: id)
        }
    }

    func loadTracks() async {
        await playlist.loadTracks()
    }

    func makeCanonical() async throws {
        guard let canonicalPlaylist = try await Playlist(makingCanonical: playlist) else { return }
        playlist = canonicalPlaylist
        await library?.add([canonicalPlaylist])
    }

    func write(segments: [Playlist.Segment] = Playlist.Segment.allCases) throws {
        try playlist.write(segments: segments)
    }
}

extension PlaylistModel {
    func getTrack(at url: URL) -> Track? {
        playlist.getTrack(at: url)
    }

    func createTrack(from url: URL) async -> Track? {
        await playlist.createTrack(from: url)
    }

    func getOrCreateTrack(at url: URL) async -> Track? {
        await playlist.getOrCreateTrack(at: url)
    }
}

extension PlaylistModel {
    func add(_ urls: [URL], at destination: Int? = nil) async {
        var tracks: [Track] = []
        for url in urls {
            guard let track = await getOrCreateTrack(at: url) else { continue }
            tracks.append(track)
        }
        playlist.add(tracks, at: destination)
    }

    func append(_ urls: [URL]) async {
        for url in urls {
            guard let track = await getOrCreateTrack(at: url) else { continue }
            playlist.add([track])
        }
    }

    func remove(_ urls: [URL]) async {
        for url in urls {
            guard let track = await getOrCreateTrack(at: url) else { continue }
            playlist.remove([track])
        }
    }

    func clear() async {
        await remove(playlist.map(\.url))
    }
}
