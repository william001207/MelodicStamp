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

    var body: some Commands {
        CommandMenu("Playlist") {
            Group {
                if let metadataEditor {
                    Button("Clear Selection") {
                        player?.selectedTracks.removeAll()
                    }
                    .disabled(!metadataEditor.hasMetadata)
                } else {
                    Button("Clear Selection") {}
                        .disabled(true)
                }
            }

            Group {
                if let player, let metadataEditor {
                    if metadataEditor.hasMetadata {
                        Button("Remove from Playlist") {
                            player.removeFromPlaylist(tracks: .init(player.selectedTracks))
                        }
                    } else {
                        Button("Clear Playlist") {
                            player.removeFromPlaylist(tracks: player.playlist)
                        }
                        .disabled(player.playlist.isEmpty)
                    }
                } else {
                    Button("Clear Playlist") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.deleteForward, modifiers: [])

            Group {
                if
                    let player,
                    player.selectedTracks.count == 1,
                    let track = player.selectedTracks.first {
                    let title = MusicTitle.stringifiedTitle(mode: .title, for: track)
                    Button {
                        player.play(track: track)
                    } label: {
                        if !title.isEmpty {
                            Text("Play \(title)")
                        } else {
                            Text("Play Selected")
                        }
                    }
                } else {
                    Button("Play Selected") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.return, modifiers: [])
        }
    }
}
