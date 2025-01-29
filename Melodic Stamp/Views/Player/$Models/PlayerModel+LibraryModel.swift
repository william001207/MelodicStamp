//
//  PlayerModel+LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

extension PlayerModel {
    @Observable final class LibraryModel {
        private(set) var index: PlaylistIndex = .read()

        var playlists: [Playlist] = [] {
            didSet {
                index.updateIDs(from: playlists)
                try? index.write()
            }
        }

        var playlist: Playlist

        init(bindingTo id: UUID) {
            self.playlist = .referenced(bindingTo: id)
        }
    }
}

extension PlayerModel.LibraryModel {
    var hasPlaylists: Bool { !playlists.isEmpty }
}

extension PlayerModel.LibraryModel {
    func movePlaylist(fromOffsets indices: IndexSet, toOffset destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)
    }

    func saveOrLoadPlaylist() async {
        guard
            !playlist.mode.isCanonical,
            var canonicalPlaylist = await Playlist(makingCanonical: playlist)
        else { return }
        await canonicalPlaylist.loadTracks()
        playlist = canonicalPlaylist

        if !playlists.contains(canonicalPlaylist) {
            playlists.append(canonicalPlaylist)
        }
    }

    func refresh() async {
        await playlists = index.loadPlaylists()
    }
}
