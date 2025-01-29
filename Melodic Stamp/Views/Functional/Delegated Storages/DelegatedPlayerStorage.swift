////
////  DelegatedPlayerStorage.swift
////  MelodicStamp
////
////  Created by KrLite on 2025/1/12.
////
//
// import Defaults
// import SwiftUI
//
// struct DelegatedPlayerStorage: View {
//    @Environment(PlayerModel.self) private var player
//
//    // MARK: Storages
//
//    @SceneStorage(AppSceneStorage.playbackVolume()) private var playbackVolume: Double?
//    @SceneStorage(AppSceneStorage.playbackMuted()) private var playbackMuted: Bool?
//
//    // MARK: States
//
//    @State private var playbackVolumeState: DelegatedSceneStorageState<Double?> = .init()
//    @State private var playbackMutedState: DelegatedSceneStorageState<Bool?> = .init()
//
//    var body: some View {
//        ZStack {
//            Color.clear
//
//            playlistObservations()
//            playbackModeObservations()
//            playbackPositionObservations()
//            playbackVolumeObservations()
//        }
//        .onAppear {
//            playlistURLsState.isReady = memorizesPlaylists
//            playbackModeState.isReady = memorizesPlaybackModes
//            playbackLoopingState.isReady = memorizesPlaybackModes
//        }
//    }
//
//    // MARK: Playlist
//
//    @ViewBuilder private func playlistObservations() -> some View {
//        Color.clear
////            .onChange(of: playlistURLs) { _, newValue in
////                playlistURLsState.value = newValue
////            }
////            .onChange(of: player.playlist) { _, newValue in
////                playlistURLsState.isReady = false
////                storePlaylistURLs(newValue)
////            }
////            .onChange(of: playlistURLsState.preparedValue) { _, newValue in
////                guard let newValue else { return }
////
////                if let string = newValue {
////                    restorePlaylistURLs(string)
////
////                    print("Successfully restored playlist tracks")
////
////                    // Dependents
////                    trackState.isReady = true
////                }
////
////                playlistURLsState.isReady = false
////            }
//
////            .onChange(of: track) { _, newValue in
////                trackState.value = newValue
////            }
////            .onChange(of: player.currentTrack) { _, newValue in
////                trackState.isReady = false
////                track = newValue?.url
////            }
////            .onChange(of: trackState.preparedValue) { _, newValue in
////                guard let newValue else { return }
////
////                if let url = newValue {
////                    player.play(url: url)
////
////                    print("Successfully restored currently playing track to \(url)")
////
////                    // Dependents
////                    playbackVolumeState.isReady = true
////                    playbackMutedState.isReady = true
////
////                    DispatchQueue.main.async {
////                        player.pause()
////                        playbackPositionState.isReady = true
////                    }
////                }
////
////                trackState.isReady = false
////            }
//    }
//
//    // MARK: Playback Mode
//
//    @ViewBuilder private func playbackModeObservations() -> some View {
//        Color.clear
//            .onChange(of: playbackMode) { _, newValue in
//                playbackModeState.value = newValue
//            }
//            .onChange(of: player.playbackMode) { _, newValue in
//                playbackModeState.isReady = false
//                playbackMode = newValue
//            }
//            .onChange(of: playbackModeState.preparedValue) { _, newValue in
//                guard let newValue else { return }
//
//                if let mode = newValue {
//                    player.playbackMode = mode
//
//                    print("Successfully restored playback mode to \(mode)")
//                }
//
//                playbackModeState.isReady = false
//            }
//
//            .onChange(of: playbackLooping) { _, newValue in
//                playbackLoopingState.value = newValue
//            }
//            .onChange(of: player.playbackLooping) { _, newValue in
//                playbackLoopingState.isReady = false
//                playbackLooping = newValue
//            }
//            .onChange(of: playbackLoopingState.preparedValue) { _, newValue in
//                guard let newValue else { return }
//
//                if let isLoopingEnabled = newValue {
//                    player.playbackLooping = isLoopingEnabled
//
//                    print("Successfully restored playback looping state to \(isLoopingEnabled)")
//                }
//
//                playbackLoopingState.isReady = false
//            }
//    }
//
//    // MARK: Playback Position
//
//    @ViewBuilder private func playbackPositionObservations() -> some View {
//        Color.clear
//            .onChange(of: playbackPosition) { _, newValue in
//                playbackPositionState.value = newValue
//            }
//            .onChange(of: player.time) { _, newValue in
//                playbackPositionState.isReady = false
//                playbackPosition = newValue
//            }
//            .onChange(of: playbackPositionState.preparedValue) { _, newValue in
//                guard let newValue else { return }
//
//                if let time = newValue {
//                    player.time = time
//
//                    print("Successfully restored playback position to \(time)")
//                }
//
//                playbackPositionState.isReady = false
//            }
//    }
//
//    // MARK: Playback Volume
//
//    @ViewBuilder private func playbackVolumeObservations() -> some View {
//        Color.clear
//            .onChange(of: playbackVolume) { _, newValue in
//                playbackVolumeState.value = newValue
//            }
//            .onChange(of: player.volume) { _, newValue in
//                playbackVolumeState.isReady = false
//                playbackVolume = newValue
//            }
//            .onChange(of: playbackVolumeState.preparedValue) { _, newValue in
//                guard let newValue else { return }
//
//                if let volume = newValue {
//                    player.volume = volume
//
//                    print("Successfully restored playback volume to \(volume)")
//                }
//
//                playbackVolumeState.isReady = false
//            }
//
//            .onChange(of: playbackMuted) { _, newValue in
//                playbackMutedState.value = newValue
//            }
//            .onChange(of: player.isMuted) { _, newValue in
//                playbackMutedState.isReady = false
//                playbackMuted = newValue
//            }
//            .onChange(of: playbackMutedState.preparedValue) { _, newValue in
//                guard let newValue else { return }
//
//                if let isMuted = newValue {
//                    player.isMuted = isMuted
//
//                    print("Successfully restored playback muted state to \(isMuted)")
//                }
//
//                playbackMutedState.isReady = false
//            }
//    }
//
//    private func restorePlaylistURLs(_ string: String) {
//        guard !string.isEmpty else { return }
//        do {
//            guard let data = Data(base64Encoded: string) else { return }
//            guard let bookmarks = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Data] else { return }
//
//            try bookmarks.forEach {
//                var isStale = false
//                let url = try URL(resolvingBookmarkData: $0, options: [], bookmarkDataIsStale: &isStale)
//                guard !isStale else { return }
//                player.addToPlaylist([url])
//            }
//        } catch {
//            fatalError("Failed to decode \(Self.self) from \(string): \(error)")
//        }
//    }
//
//    private func storePlaylistURLs(_ tracks: [Track]) {
//        if !tracks.isEmpty {
//            do {
//                let bookmarks: [Data] = try tracks.map(\.url).compactMap { url in
//                    try url.bookmarkData(options: [])
//                }
//                let data = try PropertyListSerialization.data(fromPropertyList: bookmarks, format: .binary, options: .zero)
//                playlistURLs = data.base64EncodedString()
//            } catch {
//                fatalError("Failed to encode \(self): \(error)")
//            }
//        } else {
//            playlistURLs = nil
//        }
//    }
// }
