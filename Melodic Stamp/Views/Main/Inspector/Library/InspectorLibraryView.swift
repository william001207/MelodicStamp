//
//  InspectorLibraryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct InspectorLibraryView: View {
    // MARK: - Environments

    @Environment(PlayerModel.self) private var player

    @Environment(\.appearsActive) private var appearsActive

    // MARK: - Fields

    @State private var selectedPlaylists: Set<Playlist> = []

    // MARK: - Body

    var body: some View {
        Group {
            if !player.library.hasPlaylists {
                ExcerptView(tab: SidebarInspectorTab.library)
            } else {
                List(selection: $selectedPlaylists) {
                    ForEach(player.library.playlists) { playlist in
                        let isSelected = selectedPlaylists.contains(playlist)
                        LibraryItemView(playlist: playlist, isSelected: isSelected)
                            .id(playlist)
                    }
                    .onMove { indices, destination in
                        withAnimation {
                            player.library.movePlaylist(fromOffsets: indices, toOffset: destination)
                        }
                    }
                    .transition(.slide)
                }
                .scrollClipDisabled()
                .scrollContentBackground(.hidden)

                // MARK: Keyboard Handlers

                // Handle [escape] -> clear selection
                .onKeyPress(.escape) {
                    if handleEscape() {
                        .handled
                    } else {
                        .ignored
                    }
                }
            }
        }
        .onChange(of: appearsActive, initial: true) { _, newValue in
            guard newValue else { return }
            Task {
                await player.library.refresh()
            }
        }
    }

    private var canEscape: Bool {
        !selectedPlaylists.isEmpty
    }

    // MARK: - Functions

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        selectedPlaylists.removeAll()
        return true
    }
}

#if DEBUG

    // MARK: - Preview

    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        InspectorLibraryView()
    }
#endif
