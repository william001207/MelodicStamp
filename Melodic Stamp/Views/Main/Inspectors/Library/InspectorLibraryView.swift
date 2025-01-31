//
//  InspectorLibraryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import QuickLook
import SwiftUI

struct InspectorLibraryView: View {
    // MARK: - Environments

    @Environment(LibraryModel.self) private var library

    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) private var appearsActive

    // MARK: - Fields

    @State private var selectedPlaylists: Set<Playlist> = []
    @State private var quickLookSelection: URL?

    // MARK: - Body

    var body: some View {
        if !library.isLoaded {
            ExcerptView(tab: SidebarInspectorTab.library)
        } else {
            List(selection: $selectedPlaylists) {
                // MARK: Playlists

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

            // MARK: Quick Look

            .quickLookPreview($quickLookSelection, in: library.playlists.map(\.url))
            .onChange(of: selectedPlaylists) { _, newValue in
                guard quickLookSelection != nil else { return }
                guard newValue.count == 1 else {
                    quickLookSelection = nil
                    return
                }
                quickLookSelection = newValue.first?.url
            }

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

                open(Array(selectedPlaylists))
                return .handled
            }

            // Handles [space] -> quick look
            .onKeyPress(.space) {
                if quickLookSelection != nil {
                    quickLookSelection = nil
                    return .handled
                } else if selectedPlaylists.count == 1 {
                    quickLookSelection = selectedPlaylists.first?.url
                    return .handled
                } else {
                    return .ignored
                }
            }
        }
    }

    private var canEscape: Bool {
        !selectedPlaylists.isEmpty
    }

    private var canRemove: Bool {
        library.isLoaded
    }

    // MARK: - Item View

    @ViewBuilder private func itemView(for playlist: Playlist) -> some View {
        let isSelected = selectedPlaylists.contains(playlist)

        LibraryItemView(
            item: playlist,
            isSelected: isSelected
        )
        .contextMenu {
            contextMenu(for: playlist)
        }
        .swipeActions {
            // MARK: Remove from Library

            Button(role: .destructive) {
                handleRemove([playlist])
            } label: {
                Image(systemSymbol: .trash)
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading) {
            // MARK: Open

            Button {
                open([playlist])
            } label: {
                Image(systemSymbol: .rectangleStackFill)
            }
            .tint(.accent)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder private func contextMenu(for playlist: Playlist) -> some View {
        // MARK: Open

        Group {
            if selectedPlaylists.count <= 1 {
                Button("Open in New Window") {
                    open([playlist])
                }
            } else {
                Button {
                    open(Array(selectedPlaylists))
                } label: {
                    Text("Open \(selectedPlaylists.count) Playlists")
                }
            }
        }
        .keyboardShortcut(.return, modifiers: [])

        // MARK: Copy

        Group {
            if selectedPlaylists.count <= 1 {
                Button("Copy Playlist") {
                    try? copy([playlist])
                }
            } else {
                Button {
                    try? copy(Array(selectedPlaylists))
                } label: {
                    Text("Copy \(selectedPlaylists.count) Playlists")
                }
            }
        }

        // MARK: Remove from Library

        Group {
            if selectedPlaylists.count <= 1 {
                Button("Remove from Library") {
                    handleRemove([playlist])
                }
            } else {
                Button {
                    handleRemove(Array(selectedPlaylists))
                } label: {
                    Text("Remove \(selectedPlaylists.count) Playlists from Library")
                }
            }
        }
        .keyboardShortcut(.deleteForward, modifiers: [])

        Divider()

        if let url = playlist.unwrappedURL {
            // MARK: Reveal in Finder

            Button("Reveal in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }

    // MARK: - Functions

    private func open(_ playlists: [Playlist]) {
        for playlist in playlists {
            openWindow(
                id: WindowID.content.rawValue,
                value: CreationParameters(playlist: .canonical(playlist.id))
            )
        }
    }

    private func copy(_ playlists: [Playlist]) throws {
        guard !playlists.isEmpty else { return }

        for playlist in playlists {
            guard
                let index = library.playlists.firstIndex(where: { $0.id == playlist.id }),
                let copiedPlaylist = try Playlist(copyingFrom: playlist)
            else { continue }
            library.add([copiedPlaylist], at: index + 1)
        }
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

    #Preview(traits: .modifier(PreviewEnvironments())) {
        InspectorLibraryView()
    }
#endif
