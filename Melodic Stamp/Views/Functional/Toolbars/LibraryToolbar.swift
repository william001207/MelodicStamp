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
            Button {
                Task {
                    await player.makePlaylistCanonical()
                }
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .docZipper)
                        .imageScale(.small)

                    Text("Add to Library")
                }
            }
            .disabled(player.playlist.isEmpty)
        }
    }
}
