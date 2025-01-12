//
//  DelegatedPlayerSceneStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct DelegatedPlayerSceneStorage: View {
    @Environment(PlayerModel.self) private var player

    @Default(.memorizesPlaylists) private var memorizesPlaylists
    @Default(.memorizesPlaybackModes) private var memorizesPlaybackModes
    @Default(.memorizesPlaybackPositions) private var memorizesPlaybackPositions
    @Default(.memorizesPlaybackVolumes) private var memorizesPlaybackVolumes

    // MARK: Storages

    @SceneStorage(AppSceneStorage.playlistURLs()) private var playlistURLs: BookmarkedURLs = []
    @SceneStorage(AppSceneStorage.track()) private var track: URL?

    @SceneStorage(AppSceneStorage.playbackMode()) private var playbackMode: PlaybackMode?
    @SceneStorage(AppSceneStorage.playbackLooping()) private var playbackLooping: Bool?

    @SceneStorage(AppSceneStorage.playbackPosition()) private var playbackPosition: TimeInterval?
    @SceneStorage(AppSceneStorage.playbackVolume()) private var playbackVolume: Double?
    @SceneStorage(AppSceneStorage.playbackMuted()) private var playbackMuted: Bool?

    // MARK: States

    @State private var playlistURLsState: DelegatedSceneStorageState<[URL]> = .init()
    @State private var trackState: DelegatedSceneStorageState<URL?> = .init()

    @State private var playbackModeState: DelegatedSceneStorageState<PlaybackMode?> = .init()
    @State private var playbackLoopingState: DelegatedSceneStorageState<Bool?> = .init()

    @State private var playbackPositionState: DelegatedSceneStorageState<TimeInterval?> = .init()
    @State private var playbackVolumeState: DelegatedSceneStorageState<Double?> = .init()
    @State private var playbackMutedState: DelegatedSceneStorageState<Bool?> = .init()

    var body: some View {
        ZStack {
            Color.clear

            playlistObservations()
            playbackModeObservations()
            playbackPositionObservations()
            playbackVolumeObservations()
        }
        .onAppear {
            playlistURLsState.isReady = memorizesPlaylists
            playbackModeState.isReady = memorizesPlaybackModes
            playbackLoopingState.isReady = memorizesPlaybackModes
        }
    }

    // MARK: Playlist

    @ViewBuilder private func playlistObservations() -> some View {
        Color.clear
            .onChange(of: playlistURLs) { _, newValue in
                playlistURLsState.value = newValue
            }
            .onChange(of: player.playlist) { _, newValue in
                storePlaylistURLs(newValue)
            }
            .onChange(of: playlistURLsState.preparedValue) { _, newValue in
                guard let newValue else { return }
                restorePlaylistURLs(newValue)
                playlistURLsState.isReady = false

                print("Successfully restored \(newValue.count) track(s) into playlist")

                // Dependents
                trackState.isReady = true
            }

            .onChange(of: track) { _, newValue in
                trackState.value = newValue
            }
            .onChange(of: player.track) { _, newValue in
                track = newValue?.url
            }
            .onChange(of: trackState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let url = newValue {
                    player.play(url: url)

                    print("Successfully restored currently playing track to \(url)")
                }
                trackState.isReady = false

                // Dependents
                playbackVolumeState.isReady = true
                playbackMutedState.isReady = true

                DispatchQueue.main.async {
                    player.pause()
                    playbackPositionState.isReady = true
                }
            }
    }

    // MARK: Playback Mode

    @ViewBuilder private func playbackModeObservations() -> some View {
        Color.clear
            .onChange(of: playbackMode) { _, newValue in
                playbackModeState.value = newValue
            }
            .onChange(of: player.playbackMode) { _, newValue in
                playbackMode = newValue
            }
            .onChange(of: playbackModeState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let mode = newValue {
                    player.playbackMode = mode

                    print("Successfully restored playback mode to \(mode)")
                }
                playbackModeState.isReady = false
            }

            .onChange(of: playbackLooping) { _, newValue in
                playbackLoopingState.value = newValue
            }
            .onChange(of: player.playbackLooping) { _, newValue in
                playbackLooping = newValue
            }
            .onChange(of: playbackLoopingState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let isLoopingEnabled = newValue {
                    player.playbackLooping = isLoopingEnabled

                    print("Successfully restored playback looping state to \(isLoopingEnabled)")
                }
                playbackLoopingState.isReady = false
            }
    }

    // MARK: Playback Position

    @ViewBuilder private func playbackPositionObservations() -> some View {
        Color.clear
            .onChange(of: playbackPosition) { _, newValue in
                playbackPositionState.value = newValue
            }
            .onChange(of: player.time) { _, newValue in
                playbackPosition = newValue
            }
            .onChange(of: playbackPositionState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let time = newValue {
                    player.time = time

                    print("Successfully restored playback position to \(time)")
                }
                playbackPositionState.isReady = false
            }
    }

    // MARK: Playback Volume

    @ViewBuilder private func playbackVolumeObservations() -> some View {
        Color.clear
            .onChange(of: playbackVolume) { _, newValue in
                playbackVolumeState.value = newValue
            }
            .onChange(of: player.volume) { _, newValue in
                playbackVolume = newValue
            }
            .onChange(of: playbackVolumeState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let volume = newValue {
                    player.volume = volume

                    print("Successfully restored playback volume to \(volume)")
                }
                playbackVolumeState.isReady = false
            }

            .onChange(of: playbackMuted) { _, newValue in
                playbackMutedState.value = newValue
            }
            .onChange(of: player.isMuted) { _, newValue in
                playbackMuted = newValue
            }
            .onChange(of: playbackMutedState.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let isMuted = newValue {
                    player.isMuted = isMuted

                    print("Successfully restored playback muted state to \(isMuted)")
                }
                playbackMutedState.isReady = false
            }
    }

    private func restorePlaylistURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        player.addToPlaylist(urls: urls)
    }

    private func storePlaylistURLs(_ tracks: [Track]) {
        if !tracks.isEmpty {
            playlistURLs = tracks.map(\.url)
        } else {
            playlistURLs = []
        }
    }
}
