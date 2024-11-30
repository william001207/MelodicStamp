//
//  FileManagerModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

enum FileOpenerPresentationStyle {
    case inCurrentPlaylist
    case replacingCurrentPlaylist
    case formingNewPlaylist
}

enum FileAdderPresentationStyle {
    case toCurrentPlaylist
    case replacingCurrentPlaylist
    case formingNewPlaylist
}

@Observable class FileManagerModel {
    var isFileOpenerPresented: Bool = false
    private var fileOpenerPresentationStyle: FileOpenerPresentationStyle = .inCurrentPlaylist
    
    var isFileAdderPresented: Bool = false
    private var fileAdderPresentationStyle: FileAdderPresentationStyle = .toCurrentPlaylist
    
    func emitOpen(style: FileOpenerPresentationStyle = .inCurrentPlaylist) {
        isFileOpenerPresented = true
        fileOpenerPresentationStyle = style
    }
    
    func emitAdd(style: FileAdderPresentationStyle = .toCurrentPlaylist) {
        isFileOpenerPresented = true
        fileAdderPresentationStyle = style
    }
    
    func open(url: URL, using player: PlayerModel) {
        switch fileOpenerPresentationStyle {
        case .inCurrentPlaylist:
            Task.detached {
                try await player.play(url: url)
            }
        case .replacingCurrentPlaylist:
            break
        case .formingNewPlaylist:
            break
        }
    }
    
    func add(urls: [URL], using player: PlayerModel) {
        switch fileAdderPresentationStyle {
        case .toCurrentPlaylist:
            Task.detached {
                try await player.addToPlaylist(urls: urls)
            }
        case .replacingCurrentPlaylist:
            break
        case .formingNewPlaylist:
            break
        }
    }
}
