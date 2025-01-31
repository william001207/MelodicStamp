//
//  DelegatedPlaylistStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

extension DelegatedPlaylistStorage: TypeNameReflectable {}

extension DelegatedPlaylistStorage {
    enum DelegatedPlaylist: Equatable, Hashable, Codable {
        case referenced(
            bookmarks: [Data],
            currentTrackURL: URL?,
            currentTrackElapsedTime: TimeInterval,
            playbackMode: PlaybackMode,
            playbackLooping: Bool
        )
        case canonical(UUID)
    }
}

struct DelegatedPlaylistStorage: View {
    @Environment(PlaylistModel.self) private var playlist
    @Environment(PlayerModel.self) private var player

    // MARK: Storages

    @SceneStorage(AppSceneStorage.playlistData()) private var playlistData: Data?

    @SceneStorage(AppSceneStorage.playbackVolume()) private var playbackVolume: Double?
    @SceneStorage(AppSceneStorage.playbackMuted()) private var playbackMuted: Bool?

    // MARK: States

    @State private var playlistState: DelegatedStorageState<Data?> = .init()

    @State private var playbackVolumeState: DelegatedStorageState<Double?> = .init()
    @State private var playbackMutedState: DelegatedStorageState<Bool?> = .init()

    var body: some View {
        ZStack {
            playlistObservations()
            playbackVolumeObservations()
        }
        .onAppear {
            playlistState.isReady = true
        }
    }

    // MARK: Playlist

    @ViewBuilder private func playlistObservations() -> some View {
        Color.clear
            .onChange(of: playlistData) { _, newValue in
                playlistState.value = newValue
            }
            .onChange(of: playlist.hashValue) { _, _ in
                playlistState.isReady = false

                Task.detached {
                    try await storePlaylist()
                }
            }
            .onChange(of: playlistState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let data = newValue {
                    Task.detached {
                        try await restorePlaylist(from: data)

                        logger.log("Successfully restored playlist")

                        #if DEBUG
                            await dump(playlist.tracks.map(\.url))
                        #endif

                        Task { @MainActor in
                            // Dependents
                            playbackVolumeState.isReady = true
                            playbackMutedState.isReady = true
                        }
                    }
                }

                playlistState.isReady = false
            }
    }

    // MARK: Playback Volume

    @ViewBuilder private func playbackVolumeObservations() -> some View {
        Color.clear
            .onChange(of: playbackVolume) { _, newValue in
                playbackVolumeState.value = newValue
            }
            .onChange(of: player.volume) { _, newValue in
                playbackVolumeState.isReady = false
                playbackVolume = newValue
            }
            .onChange(of: playbackVolumeState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let volume = newValue {
                    player.volume = volume

                    logger.log("Successfully restored playback volume to \(volume)")
                }

                playbackVolumeState.isReady = false
            }

            .onChange(of: playbackMuted) { _, newValue in
                playbackMutedState.value = newValue
            }
            .onChange(of: player.isMuted) { _, newValue in
                playbackMutedState.isReady = false
                playbackMuted = newValue
            }
            .onChange(of: playbackMutedState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let isMuted = newValue {
                    player.isMuted = isMuted

                    logger.log("Successfully restored playback muted state to \(isMuted)")
                }

                playbackMutedState.isReady = false
            }
    }

    private func restorePlaylist(from data: Data) async throws {
        guard let delegatedPlaylist = try? JSONDecoder().decode(DelegatedPlaylist.self, from: data) else { return }
        switch delegatedPlaylist {
        case let .referenced(bookmarks, currentTrackURL, currentTrackElapsedTime, playbackMode, playbackLooping):
            guard !playlist.mode.isCanonical else { break }

            var urls: [URL] = []
            try bookmarks.forEach {
                var isStale = false
                let url = try URL(resolvingBookmarkData: $0, options: [], bookmarkDataIsStale: &isStale)
                guard !isStale else { return }
                urls.append(url)
            }
            await playlist.append(urls)

            playlist.segments.state = .init(
                currentTrackURL: currentTrackURL,
                currentTrackElapsedTime: currentTrackElapsedTime,
                playbackMode: playbackMode,
                playbackLooping: playbackLooping
            )
        case let .canonical(id):
            switch playlist.mode {
            case .canonical:
                // Already handled by `ContentView`
                break
            case .referenced:
                playlist.bindTo(id, mode: .canonical)
                playlist.loadTracks()
            }
        }
    }

    private func storePlaylist() async throws {
        let delegatedPlaylist: DelegatedPlaylist
        switch playlist.mode {
        case .canonical:
            delegatedPlaylist = .canonical(playlist.id)
        case .referenced:
            let bookmarks: [Data] = try playlist.map(\.url).compactMap { url in
                try url.bookmarkData(options: [])
            }

            delegatedPlaylist = .referenced(
                bookmarks: bookmarks,
                currentTrackURL: playlist.segments.state.currentTrackURL,
                currentTrackElapsedTime: playlist.segments.state.currentTrackElapsedTime,
                playbackMode: playlist.segments.state.playbackMode,
                playbackLooping: playlist.segments.state.playbackLooping
            )
        }
        playlistData = try? JSONEncoder().encode(delegatedPlaylist)
    }
}
