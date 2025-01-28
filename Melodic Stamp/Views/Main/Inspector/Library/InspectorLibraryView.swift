//
//  InspectorLibraryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct InspectorLibraryView: View {
    @Environment(LibraryModel.self) private var library

    @State private var selectedPlaylist: Playlist?

    var body: some View {
        List(selection: $selectedPlaylist) {
            ForEach(library.playlists) { playlist in
                LibraryItemView(playlist: playlist)
                    .id(playlist)
            }
        }
        .scrollClipDisabled()
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        InspectorLibraryView()
    }
#endif
