//
//  PlayerModel+LibraryModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/29.
//

import Foundation

extension PlayerModel {
    @Observable final class LibraryModel {
        var playlists: [Playlist] = []
        var playlist: Playlist

        init(bindingTo id: UUID) {
            self.playlist = .referenced(bindingTo: id)
        }
    }
}

extension PlayerModel.LibraryModel {
    func movePlaylist(from indices: IndexSet, to destination: Int) {
        playlists.move(fromOffsets: indices, toOffset: destination)
    }

    func saveOrLoadPlaylist() async {
        guard
            !playlist.mode.isCanonical,
            let canonicalPlaylist = await Playlist(makingCanonical: playlist)
        else { return }
        playlist = canonicalPlaylist
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
            guard let id = UUID(uuidString: pathName), let playlist = await Playlist(loadingWith: id) else { continue }

            playlists.append(playlist)
        }
    }
}
