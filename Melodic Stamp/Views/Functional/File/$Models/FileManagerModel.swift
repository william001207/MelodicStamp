//
//  FileManagerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/25.
//

import CSFBAudioEngine
import SwiftUI
import UniformTypeIdentifiers

enum FileOpenerPresentationStyle {
    case inCurrentPlaylist
    case replacingCurrentPlaylistOrSelection
    case formingNewPlaylist
}

enum FileAdderPresentationStyle {
    case toCurrentPlaylist
    case replacingCurrentPlaylistOrSelection
    case formingNewPlaylist
}

@Observable class FileManagerModel {
    private weak var player: PlayerModel?

    var isFileOpenerPresented: Bool = false
    private var fileOpenerPresentationStyle: FileOpenerPresentationStyle = .inCurrentPlaylist

    var isFileAdderPresented: Bool = false
    private var fileAdderPresentationStyle: FileAdderPresentationStyle = .toCurrentPlaylist

    init(player: PlayerModel) {
        self.player = player
    }

    func emitOpen(style: FileOpenerPresentationStyle = .inCurrentPlaylist) {
        isFileOpenerPresented = true
        fileOpenerPresentationStyle = style
    }

    func emitAdd(style: FileAdderPresentationStyle = .toCurrentPlaylist) {
        isFileAdderPresented = true
        fileAdderPresentationStyle = style
    }

    func open(url: URL, openWindow: OpenWindowAction) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        Task { @MainActor in
            switch fileOpenerPresentationStyle {
            case .inCurrentPlaylist:
                player?.play(url)
            case .replacingCurrentPlaylistOrSelection:
                player?.clearPlaylist()
                player?.play(url)
            case .formingNewPlaylist:
                openWindow(id: WindowID.content.rawValue, value: CreationParameters(
                    playlist: .referenced([url]), shouldPlay: true,
                    initialWindowStyle: .miniPlayer
                ))
            }
        }
    }

    func add(urls: [URL], openWindow: OpenWindowAction) {
        let urls = urls.flatMap { url in
            FileHelper.flatten(contentsOf: url)
        }

        Task { @MainActor in
            switch fileAdderPresentationStyle {
            case .toCurrentPlaylist:
                player?.addToPlaylist(urls)
            case .replacingCurrentPlaylistOrSelection:
                player?.clearPlaylist()
                player?.addToPlaylist(urls)
            case .formingNewPlaylist:
                openWindow(id: WindowID.content.rawValue, value: CreationParameters(
                    playlist: .referenced(urls)
                ))
            }
        }
    }
}
