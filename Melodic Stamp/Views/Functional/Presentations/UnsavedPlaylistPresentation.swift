//
//  UnsavedPlaylistPresentation.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/2/1.
//

import SwiftUI

struct UnsavedPlaylistPresentation: View {
    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(PresentationManagerModel.self) private var presentationManager
    @Environment(PlaylistModel.self) private var playlist

    var body: some View {
        @Bindable var presentationManager = presentationManager

        if playlist.canMakeCanonical {
            Color.clear
                .alert("Unsaved Playlist", isPresented: $presentationManager.isUnsavedPlaylistAlertPresented) {
                    Button("")
                }
        } else {
            Color.clear
                .onChange(of: presentationManager.state) { _, newValue in
                    guard newValue == .unsavedPlaylistAlert else { return }
                    presentationManager.nextStage()
                }
        }
    }
}
