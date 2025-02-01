//
//  LibraryToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Defaults
import SwiftUI

struct LibraryToolbar: CustomizableToolbarContent {
    @Environment(LibraryModel.self) private var library
    @Environment(PresentationManagerModel.self) private var presentationManager
    @Environment(PlaylistModel.self) private var playlist

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.dismissWindow) private var dismissWindow

    @Default(.asksForPlaylistInformation) private var asksForPlaylistInformation

    var body: some CustomizableToolbarContent {
        @Bindable var playlist = playlist

        if !playlist.mode.isCanonical {
            ToolbarItem(id: ToolbarItemID.libraryAdd()) {
                Button {
                    presentationManager.isPlaylistSegmentsSheetPresented = asksForPlaylistInformation
                    Task.detached {
                        try await playlist.makeCanonical()
                    }
                } label: {
                    Label("Add to Library", systemSymbol: .trayFullFill)
                }
                .disabled(!playlist.canMakeCanonical)
            }
        } else {
            ToolbarItem(id: ToolbarItemID.libraryRemove()) {
                Button {
                    presentationManager.isPlaylistRemovalAlertPresented = true
                } label: {
                    Label("Remove from Library", systemSymbol: .trashFill)
                }
                .tint(.red)
            }
        }
    }
}
