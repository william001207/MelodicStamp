//
//  FileToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct FileToolbar: View {
    @Bindable var player: PlayerModel
    @Bindable var fileManager: FileManagerModel

    var body: some View {
        Menu {
            Button {
                fileManager.emitOpen(style: .inCurrentPlaylist)
            } label: {
                Image(systemSymbol: .textLineLastAndArrowtriangleForward)
                Text("In Current Playlist")
            }

            Button {
                fileManager.emitOpen(style: .replacingCurrentPlaylistOrSelection)
            } label: {
                Image(systemSymbol: .textInsert)
                Text("Replacing Current Playlist")
            }

            Divider()

            Button {
                fileManager.emitOpen(style: .formingNewPlaylist)
            } label: {
                Image(systemSymbol: .textBadgePlus)
                Text("Forming New Playlist")
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

            Button {
                fileManager.emitAdd(style: .replacingCurrentPlaylistOrSelection)
            } label: {
                Image(systemSymbol: .textInsert)
                Text("Replacing Current Playlist")
            }

            Divider()

            Button {
                fileManager.emitAdd(style: .formingNewPlaylist)
            } label: {
                Image(systemSymbol: .textBadgePlus)
                Text("Forming New Playlist")
            }
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .plus)
            }
        }
    }
}
