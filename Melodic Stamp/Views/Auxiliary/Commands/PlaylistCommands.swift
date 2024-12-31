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
                        metadataEditor.items.removeAll()
                    }
                    .disabled(metadataEditor.items.isEmpty)
                } else {
                    Button("Clear Selection") {}
                        .disabled(true)
                }
            }

            Group {
                if let player, let metadataEditor {
                    if metadataEditor.items.isEmpty {
                        Button("Remove All") {
                            player.removeFromPlaylist(items: player.playlist)
                            metadataEditor.items.removeAll()
                        }
                        .disabled(player.playlist.isEmpty)
                    } else {
                        Button("Remove from Playlist") {
                            player.removeFromPlaylist(items: .init(metadataEditor.items))
                            metadataEditor.items.removeAll()
                        }
                    }
                } else {
                    Button("Remove All") {}
                        .disabled(true)
                }
            }
            .keyboardShortcut(.deleteForward, modifiers: [])

            Group {
                if
                    let player, let metadataEditor,
                    metadataEditor.items.count == 1,
                    let item = metadataEditor.items.first {
                    let title = MusicTitle.stringifiedTitle(mode: .title, for: item)
                    Button {
                        player.play(item: item)
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
