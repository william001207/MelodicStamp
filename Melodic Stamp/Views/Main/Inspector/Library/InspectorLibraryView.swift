//
//  InspectorLibraryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct InspectorLibraryView: View {
    @State var playlists: [Playlist]
    @Binding var selectedPlaylist: Playlist?

    var body: some View {
        List(selection: $selectedPlaylist) {
            ForEach(playlists) { playlist in
                LibraryPlaylistView(playlist: playlist)
                    .id(playlist)
            }
        }
        .scrollClipDisabled()
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var playlists: [Playlist] = [SampleEnvironmentsPreviewModifier.samplePlaylist]
        @Previewable @State var selectedPlaylist: Playlist?

        InspectorLibraryView(playlists: playlists, selectedPlaylist: $selectedPlaylist)
    }
#endif
