//
//  ModifiedMetadataList.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

struct ModifiedMetadataList: View {
    @Environment(PlayerModel.self) private var player

    var body: some View {
        List {
            ForEach(tracks) { track in
                Section {
                    HStack {
                        TrackPreview(track: track, titleEntry: \.current)

                        Spacer()

                        Button("Save") {
                            Task {
                                try await track.metadata.write()
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.accent)
                    }
                } header: {
                    Text(track.url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var tracks: [Track] {
        player.playlist
            .filter(\.metadata.isModified)
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        ModifiedMetadataList()
    }
#endif
