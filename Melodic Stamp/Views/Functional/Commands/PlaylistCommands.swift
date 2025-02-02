//
//  PlaylistCommands.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

struct PlaylistCommands: Commands {
    @FocusedValue(PresentationManagerModel.self) private var presentationManager
    @FocusedValue(PlaylistModel.self) private var playlist
    @FocusedValue(PlayerModel.self) private var player
    @FocusedValue(MetadataEditorModel.self) private var metadataEditor

    @Bindable var library: LibraryModel

    @State private var isRemoveAllAlertPresented = false

    var body: some Commands {
        CommandMenu("Playlist") {
            if isCanonical {
                // MARK: Remove from Library

                Button("Remove from Library") {
                    presentationManager?.isPlaylistRemovalAlertPresented = true
                }
            } else {
                // MARK: Add to Library

                Button("Add to Library") {
                    Task.detached {
                        try await playlist?.makeCanonical()
                    }
                }
                .disabled(!canMakeCanonical)
            }

            Divider()

            // MARK: Clear Selection

            Button("Clear Selection") {
                handleEscape()
            }
            .disabled(selectedTracks.isEmpty)

            // MARK: Copy Selection

            Group {
                if selectedTracks.isEmpty {
                    Button("Copy Selected Track") {}
                } else {
                    Button {
                        Task {
                            await copy(Array(selectedTracks))
                        }
                    } label: {
                        if selectedTracks.count == 1 {
                            Text("Copy Selected Track")
                        } else {
                            Text("Copy \(selectedTracks.count) Tracks")
                        }
                    }
                }
            }
            .disabled(selectedTracks.isEmpty)

            // MARK: Remove Selection

            Group {
                if selectedTracks.isEmpty {
                    Button("Remove Selected Track from Playlist") {}
                } else {
                    Button {
                        handleRemove(selectedTracks.map(\.url))
                    } label: {
                        if selectedTracks.count == 1 {
                            Text("Remove Selected Track from Playlist")
                        } else {
                            Text("Remove \(selectedTracks.count) Tracks from Playlist")
                        }
                    }
                }
            }
            .disabled(selectedTracks.isEmpty)
            .keyboardShortcut(.deleteForward, modifiers: [])

            Divider()

            // MARK: Play Selection

            Group {
                if
                    let player,
                    let playlist,
                    playlist.selectedTracks.count == 1,
                    let track = selectedTracks.first {
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

    private var isCanonical: Bool {
        playlist?.mode.isCanonical ?? false
    }

    private var canMakeCanonical: Bool {
        playlist?.canMakeCanonical ?? false
    }

    private var selectedTracks: Set<Track> {
        playlist?.selectedTracks ?? []
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
