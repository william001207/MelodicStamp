//
//  PlaylistCommands.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

struct PlaylistCommands: Commands {
    @FocusedValue(PlaylistModel.self) private var playlist
    @FocusedValue(PlayerModel.self) private var player
    @FocusedValue(MetadataEditorModel.self) private var metadataEditor

    @Bindable var library: LibraryModel

    @State private var isRemoveAllAlertPresented = false

    var body: some Commands {
        CommandMenu("Playlist") {
            Group {
                if let playlist {
                    Button("Add to Library") {
                        Task.detached {
                            try await playlist.makeCanonical()
                        }
                    }
                    .disabled(!playlist.canMakeCanonical)
                } else {
                    Button("Add to Library") {}
                        .disabled(true)
                }
            }

            Divider()

            Group {
                if let playlist {
                    Button("Clear Selection") {
                        handleEscape()
                    }
                    .disabled(playlist.selectedTracks.isEmpty)
                } else {
                    Button("Clear Selection") {}
                        .disabled(true)
                }
            }

            Group {
                if let playlist {
                    Group {
                        if playlist.selectedTracks.isEmpty {
                            Button("Copy Selected Track") {}
                        } else {
                            Button {
                                Task {
                                    await copy(Array(playlist.selectedTracks))
                                }
                            } label: {
                                if playlist.selectedTracks.count == 1 {
                                    Text("Copy Selected Track")
                                } else {
                                    Text("Copy \(playlist.selectedTracks.count) Tracks")
                                }
                            }
                        }
                    }
                    .disabled(playlist.selectedTracks.isEmpty)
                } else {
                    Button("Copy Selected Track") {}
                        .disabled(true)
                }
            }

            Group {
                if let playlist {
                    Group {
                        if playlist.selectedTracks.isEmpty {
                            Button("Remove Selected Track from Playlist") {}
                        } else {
                            Button {
                                handleRemove(playlist.selectedTracks.map(\.url))
                            } label: {
                                if playlist.selectedTracks.count == 1 {
                                    Text("Remove Selected Track from Playlist")
                                } else {
                                    Text("Remove \(playlist.selectedTracks.count) Tracks from Playlist")
                                }
                            }
                        }
                    }
                    .disabled(playlist.selectedTracks.isEmpty)
                } else {
                    Button("Remove Selected Track from Playlist") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.deleteForward, modifiers: [])

            Divider()

            Group {
                if
                    let player, let playlist,
                    playlist.selectedTracks.count == 1,
                    let track = playlist.selectedTracks.first {
                    let title = MusicTitle.stringifiedTitle(mode: .title, for: track)
                    Button {
                        player.play(track)
                    } label: {
                        if !title.isEmpty {
                            if playlist.currentTrack == track {
                                Text("Replay \(title)")
                            } else {
                                Text("Play \(title)")
                            }
                        } else {
                            if playlist.currentTrack == track {
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
        guard let playlist, !tracks.isEmpty else { return }

        for track in tracks {
            guard
                let index = playlist.tracks.firstIndex(where: { $0.id == track.id }),
                let copiedTrack = await playlist.createTrack(from: track.url)
            else { continue }
            await playlist.add([copiedTrack.url], at: index + 1)
        }
    }

    private func handleEscape() {
        guard let playlist else { return }
        playlist.selectedTracks.removeAll()
    }

    private func handleRemove(_ urls: [URL]) {
        guard let playlist else { return }
        Task {
            await playlist.remove(urls)
        }
    }
}
