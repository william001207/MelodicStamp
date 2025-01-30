//
//  LibraryPlaylistSegmentsEditorView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/30.
//

import SwiftUI

struct LibraryPlaylistSegmentsEditorView: View {
    @Binding var segments: Playlist.Segments

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var segments: Playlist.Segments = SampleEnvironmentsPreviewModifier.samplePlaylistSegments

        LibraryPlaylistSegmentsEditorView(segments: $segments)
    }
#endif
