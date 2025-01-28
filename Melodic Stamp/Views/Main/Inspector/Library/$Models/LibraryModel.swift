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

    func move(from indices: IndexSet, to destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)
    }

    func refresh() async {
        playlists.removeAll()
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: .playlists,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for content in contents.filter(\.hasDirectoryPath) {
            let pathName = content.lastPathComponent
            guard let id = UUID(uuidString: pathName), let playlist = await Playlist(indexedBy: id) else { continue }

            playlists.append(playlist)
        }
    }

    func makeCurrentPlaylistPermanent() async {
        guard
            let currentPlaylist,
            !currentPlaylist.mode.isCanonical,
            let permanentPlaylist = await Playlist(makingPermanent: currentPlaylist)
        else { return }
        self.currentPlaylist = permanentPlaylist
        playlists.append(permanentPlaylist)
    }
}
