//
//  FileCommands.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct FileCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Menu("Open File") {
                Button("In Current Playlist") {
                    
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Replacing Current Playlist") {
                    
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Form New Playlist") {
                    
                }
                .keyboardShortcut("o", modifiers: [.command, .shift, .option])
            }
            
            Menu("Add Files") {
                Button("To Current Playlist") {
                    
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Button("Replacing Current Playlist") {
                    
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Form New Playlist") {
                    
                }
                .keyboardShortcut("a", modifiers: [.command, .shift, .option])
            }
        }
    }
}
