//
//  InspectorLibraryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import SwiftUI

struct InspectorLibraryView: View {
    // MARK: - Environments

    @Environment(LibraryModel.self) private var library

    @Environment(\.appearsActive) private var appearsActive

    // MARK: - Fields

    @State private var selectedPlaylists: Set<Playlist> = []

    // MARK: - Body

    var body: some View {
        if !library.hasPlaylists {
            ExcerptView(tab: SidebarInspectorTab.library)
        } else {
            List(selection: $selectedPlaylists) {
                ForEach(library.playlists) { playlist in
                    let isSelected = selectedPlaylists.contains(playlist)
                    LibraryItemView(playlist: playlist, isSelected: isSelected)
                        .id(playlist)
                }
                .onMove { indices, destination in
                    withAnimation {
                        library.move(fromOffsets: indices, toOffset: destination)
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
