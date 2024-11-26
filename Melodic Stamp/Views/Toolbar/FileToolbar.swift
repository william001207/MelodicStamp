//
//  FileToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI
import SFSafeSymbols

struct FileToolbar: View {
    @Bindable var player: PlayerModel
    @Bindable var fileManager: FileManagerModel
    
    var body: some View {
        Menu {
            Button("In Current Playlist") {
                fileManager.fileOpenerPresentationStyle = .inCurrentPlaylist
                fileManager.isFileOpenerPresented = true
            }
            .keyboardShortcut("o", modifiers: .command)
            
            Button("Replacing Current Playlist") {
                fileManager.fileOpenerPresentationStyle = .replacingCurrentPlaylist
                fileManager.isFileOpenerPresented = true
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Form New Playlist") {
                fileManager.fileOpenerPresentationStyle = .formNewPlaylist
                fileManager.isFileOpenerPresented = true
            }
            .keyboardShortcut("o", modifiers: [.command, .shift, .option])
        } label: {
            ToolbarLabel {
                Text("Open")
            }
        }
        
        Menu {
            Button("To Current Playlist") {
                fileManager.fileAdderPresentationStyle = .toCurrentPlaylist
                fileManager.isFileAdderPresented = true
            }
            .keyboardShortcut("p", modifiers: .command)
            
            Button("Replacing Current Playlist") {
                fileManager.fileAdderPresentationStyle = .replacingCurrentPlaylist
                fileManager.isFileAdderPresented = true
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Form New Playlist") {
                fileManager.fileAdderPresentationStyle = .formNewPlaylist
                fileManager.isFileAdderPresented = true
            }
            .keyboardShortcut("p", modifiers: [.command, .shift, .option])
        } label: {
            ToolbarLabel {
                Text("Add")
            }
        }
    }
}
