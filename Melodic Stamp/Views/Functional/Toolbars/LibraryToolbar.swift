//
//  LibraryToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryToolbar: View {
    @Environment(LibraryModel.self) private var library

    var body: some View {
        Button("Make Permanent") {
            Task {
                await library.makeCurrentPlaylistPermanent()
            }
        }
        .disabled(library.currentPlaylist?.mode.isCanonical ?? true)
    }
}
