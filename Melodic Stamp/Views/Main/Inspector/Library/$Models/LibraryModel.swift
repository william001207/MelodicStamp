//
//  LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

@MainActor @Observable final class LibraryModel {
    weak var player: PlayerModel?

    private(set) var playlists: [Playlist] = []
    var currentPlaylist: Playlist? {
        get {
            player?.playlist
        }

        set {
            guard let newValue else { return }
            player?.setPlaylist(newValue)
        }
    }

    init(player: PlayerModel?) {
        self.player = player
    }
}
