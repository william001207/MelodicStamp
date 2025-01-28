//
//  LibraryPlaylistView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryPlaylistView: View {
    var playlist: Playlist

    var body: some View {
        Text("Playlist \(playlist.id)")
    }
}

#if DEBUG
    #Preview {
        LibraryPlaylistView(playlist: SampleEnvironmentsPreviewModifier.samplePlaylist)
    }
#endif
