//
//  PlaylistCommands.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

struct PlaylistCommands: Commands {
    @FocusedValue(\.player) private var player
    @FocusedValue(\.metadataEditor) private var metadataEditor

    @Bindable var library: LibraryModel

    @State private var isRemoveAllAlertPresented = false

    var body: some Commands {
        CommandMenu("Playlist") {
            Group {
                if let player {
                    Button("Add to Library") {
                        Task.detached {
                            try await player.makePlaylistCanonical()
                        }
                    }
                    .disabled(!player.playlistStatus.canMakeCanonical)
                } else {
                    Button("Add to Library") {}
                        .disabled(true)
                }
            }

            Divider()

            Group {
                if let player {
                    Button("Clear Selection") {
                        handleEscape()
                    }
                    .disabled(player.selectedTracks.isEmpty)
                } else {
                    Button("Clear Selection") {}
                        .disabled(true)
                }
            }

            Group {
                if let player {
                    Group {
                        if player.selectedTracks.isEmpty {
                            Button("Copy Selected Track") {}
                        } else {
                            Button {
                                Task {
                                    await copy(Array(player.selectedTracks))
                                }
                            } label: {
                                if player.selectedTracks.count == 1 {
                                    Text("Copy Selected Track")
                                } else {
                                    Text("Copy \(player.selectedTracks.count) Tracks")
                                }
                            }
                        }
                    }
                    .disabled(player.selectedTracks.isEmpty)
                } else {
                    Button("Copy Selected Track") {}
                        .disabled(true)
                }
            }

            Group {
                if let player {
                    Group {
                        if player.selectedTracks.isEmpty {
                            Button("Remove Selected Track from Playlist") {}
                        } else {
                            Button {
                                handleRemove(player.selectedTracks.map(\.url))
                            } label: {
                                if player.selectedTracks.count == 1 {
                                    Text("Remove Selected Track from Playlist")
                                } else {
                                    Text("Remove \(player.selectedTracks.count) Tracks from Playlist")
                                }
                            }
                        }
                    }
                    .disabled(player.selectedTracks.isEmpty)
                } else {
                    Button("Remove Selected Track from Playlist") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.deleteForward, modifiers: [])

            Divider()

            Group {
                if
                    let player,
                    player.selectedTracks.count == 1,
                    let track = player.selectedTracks.first {
                    let title = MusicTitle.stringifiedTitle(mode: .title, for: track)
                    Button {
                        player.play(track.url)
                    } label: {
                        if !title.isEmpty {
                            if player.currentTrack == track {
                                Text("Replay \(title)")
                            } else {
                                Text("Play \(title)")
                            }
                        } else {
                            if player.currentTrack == track {
                                Text("Replay Selected Track")
                            } else {
                                Text("Play Selected Track")
                            }
                        }
                    }
                } else {
                    Button("Play Selected Track") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.return, modifiers: [])
        }
    }

    private func copy(_ tracks: [Track]) async {
        guard let player, !tracks.isEmpty else { return }

        for track in tracks {
            guard
                let index = player.tracks.firstIndex(where: { $0.id == track.id }),
                let copiedTrack = await player.createTrack(from: track.url)
            else { continue }
            await player.addToPlaylist([copiedTrack.url], at: index + 1)
        }
    }

    private func handleEscape() {
        guard let player else { return }
        player.selectedTracks.removeAll()
    }

    private func handleRemove(_ urls: [URL]) {
        guard let player else { return }
        Task {
            await player.removeFromPlaylist(urls)
        }
    }
}
