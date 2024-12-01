//
//  EditingCommands.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct EditingCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .textEditing) {
            Button("Set to Undefined") {}
                .keyboardShortcut(.delete, modifiers: [.command, .shift])

            Button("Revert") {}
                .keyboardShortcut(.deleteForward, modifiers: .command)
        }
    }
}
