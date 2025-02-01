//
//  LibraryToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Defaults
import SwiftUI

struct LibraryToolbar: View {
    @Environment(LibraryModel.self) private var library
    @Environment(PresentationManagerModel.self) private var presentationManager
    @Environment(PlaylistModel.self) private var playlist

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.dismissWindow) private var dismissWindow

    @Default(.asksForPlaylistInformation) private var asksForPlaylistInformation

    var body: some View {
        @Bindable var playlist = playlist

        if !playlist.mode.isCanonical {
            Button {
                presentationManager.isPlaylistSegmentsSheetPresented = asksForPlaylistInformation
                Task.detached {
                    try await playlist.makeCanonical()
                }
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .trayFullFill)
                        .imageScale(.small)

                    Text("Add to Library")
                }
            }
            .disabled(!playlist.canMakeCanonical)
        } else {
            Button {
                presentationManager.isPlaylistRemovalAlertPresented = true
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .trashFill)
                        .imageScale(.small)

                    Text("Remove from Library")
                }
                .foregroundStyle(.red)
            }
        }
    }
}
