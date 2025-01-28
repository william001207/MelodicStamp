//
//  LibraryToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryToolbar: View {
    @Environment(PlayerModel.self) private var player

    var body: some View {
        if !player.playlist.mode.isCanonical {
            Button("Add to Library") {
                Task {
                    await player.makePlaylistCanonical()
                }
            }
        }
    }
}
