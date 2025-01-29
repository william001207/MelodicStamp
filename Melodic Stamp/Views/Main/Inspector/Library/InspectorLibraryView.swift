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

    @State private var selectedPlaylist: Playlist?

    // MARK: - Body

    var body: some View {
        List(selection: $selectedPlaylist) {
            ForEach(player.library.playlists) { playlist in
                LibraryItemView(playlist: playlist, isSelected: selectedPlaylist == playlist)
                    .id(playlist)
            }
        }
        .scrollClipDisabled()
        .scrollContentBackground(.hidden)
        .onChange(of: appearsActive, initial: true) { _, newValue in
            guard newValue else { return }
            Task {
                await player.library.refresh()
            }
        }

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

    private var canEscape: Bool {
        selectedPlaylist != nil
    }

    // MARK: - Functions

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        selectedPlaylist = nil
        return true
    }
}

#if DEBUG

    // MARK: - Preview

    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        InspectorLibraryView()
    }
#endif
