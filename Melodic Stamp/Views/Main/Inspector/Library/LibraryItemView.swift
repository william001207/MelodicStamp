//
//  LibraryItemView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct LibraryItemView: View {
    var playlist: Playlist

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                if hasTitle {
                    Text(playlist.information.info.title)
                        .bold()
                        .font(.title3)

                    Text(playlist.id.shortString)
                        .monospaced()
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                } else {
                    Text("Playlist \(playlist.id.uuidString)")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var hasTitle: Bool {
        !playlist.information.info.title.isEmpty
    }
}

#if DEBUG
    #Preview {
        LibraryItemView(playlist: SampleEnvironmentsPreviewModifier.samplePlaylist)
    }
#endif
