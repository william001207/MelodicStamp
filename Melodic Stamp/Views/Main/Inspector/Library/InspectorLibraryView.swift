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

    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) private var appearsActive

    // MARK: - Fields

    @State private var selectedPlaylists: Set<Playlist> = []

    // MARK: - Body

    var body: some View {
        if library.isEmpty {
            ExcerptView(tab: SidebarInspectorTab.library)
        } else {
            List(selection: $selectedPlaylists) {
                ForEach(library.playlists) { playlist in
                    itemView(for: playlist)
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

            // Handles [escape] -> clear selection
            .onKeyPress(.escape) {
                if handleEscape() {
                    .handled
                } else {
                    .ignored
                }
            }

            // Handles [􁂒] -> remove selection
            .onKeyPress(.deleteForward) {
                if handleRemove(Array(selectedPlaylists)) {
                    .handled
                } else {
                    .ignored
                }
            }

            // Handles [⏎] -> open selection
            .onKeyPress(.return) {
                guard !selectedPlaylists.isEmpty else { return .ignored }

                selectedPlaylists.forEach(open)
                return .handled
            }
        }
    }

    private var canEscape: Bool {
        !selectedPlaylists.isEmpty
    }

    private var canRemove: Bool {
        !library.isEmpty
    }

    // MARK: - Item View

    @ViewBuilder private func itemView(for playlist: Playlist) -> some View {
        let isSelected = selectedPlaylists.contains(playlist)

        LibraryItemView(
            playlist: playlist,
            isSelected: isSelected
        )
        .contextMenu {
            contextMenu(for: playlist)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder private func contextMenu(for playlist: Playlist) -> some View {
        if let url = playlist.canonicalURL {
            Button("Reveal in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }

    // MARK: - Functions

    private func open(_ playlist: Playlist) {
        openWindow(
            id: WindowID.content.rawValue,
            value: CreationParameters(playlist: .canonical(playlist.id))
        )
    }

    @discardableResult private func handleEscape() -> Bool {
        guard canEscape else { return false }
        selectedPlaylists.removeAll()
        return true
    }

    @discardableResult private func handleRemove(_ playlists: [Playlist]) -> Bool {
        guard canRemove else { return false }
        library.remove(playlists)
        return true
    }
}

#if DEBUG

    // MARK: - Preview

    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
        InspectorLibraryView()
    }
#endif
