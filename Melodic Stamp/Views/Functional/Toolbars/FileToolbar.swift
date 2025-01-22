//
//  FileToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct FileToolbar: View {
    @Environment(FileManagerModel.self) private var fileManager
    @Environment(PlayerModel.self) private var player

    var body: some View {
        Menu {
            Button {
                fileManager.emitOpen(style: .inCurrentPlaylist)
            } label: {
                Image(systemSymbol: .textLineLastAndArrowtriangleForward)
                Text("In Current Playlist")
            }
            .keyboardShortcut("o", modifiers: [])

            Button {
                fileManager.emitOpen(style: .replacingCurrentPlaylistOrSelection)
            } label: {
                Image(systemSymbol: .textInsert)
                Text("Replacing Current Playlist")
            }
            .keyboardShortcut("o", modifiers: .shift)
            .modifierKeyAlternate(.option) {
                Button {
                    fileManager.emitOpen(style: .formingNewPlaylist)
                } label: {
                    Image(systemSymbol: .textBadgePlus)
                    Text("Forming New Playlist")
                }
            }
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .playFill)
            }
        }

        Menu {
            Button {
                fileManager.emitAdd(style: .toCurrentPlaylist)
            } label: {
                Image(systemSymbol: .textLineLastAndArrowtriangleForward)
                Text("To Current Playlist")
            }
            .keyboardShortcut("p", modifiers: [])

            Button {
                fileManager.emitAdd(style: .replacingCurrentPlaylistOrSelection)
            } label: {
                Image(systemSymbol: .textInsert)
                Text("Replacing Current Playlist")
            }
            .keyboardShortcut("p", modifiers: .shift)
            .modifierKeyAlternate(.option) {
                Button {
                    fileManager.emitAdd(style: .formingNewPlaylist)
                } label: {
                    Image(systemSymbol: .textBadgePlus)
                    Text("Forming New Playlist")
                }
            }
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .plus)
            }
        }
    }
}
