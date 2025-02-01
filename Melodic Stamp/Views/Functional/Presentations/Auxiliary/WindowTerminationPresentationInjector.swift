//
//  WindowTerminationPresentationInjector.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

struct WindowTerminationPresentationInjector<Parent>: View where Parent: View {
    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(PresentationManagerModel.self) private var presentationManager
    @Environment(PlaylistModel.self) private var playlist
    @Environment(PlayerModel.self) private var player

    @Environment(\.appDelegate) private var appDelegate

    var window: NSWindow?
    @ViewBuilder var parent: () -> Parent

    var body: some View {
        parent()
            .background(MakeCloseDelegated(shouldClose: windowShouldClose) { window, shouldClose in
                if shouldClose {
                    player.stop()
                    appDelegate?.destroy(window: window)
                } else {
                    presentationManager.startStaging()
                    appDelegate?.suspend(window: window)
                }
            })
    }

    private var hasUnsavedChanges: Bool {
        playlist.metadataSet.contains(where: \.isModified)
    }

    private var hasUnsavedPlaylist: Bool {
        playlist.canMakeCanonical
    }

    private var windowShouldClose: Bool {
        windowManager.state.shouldForceClose || (!hasUnsavedChanges && playlist.mode.isCanonical)
    }
}

struct WindowTerminationPresentationInjectorModifier: ViewModifier {
    var window: NSWindow?

    func body(content: Content) -> some View {
        WindowTerminationPresentationInjector(window: window) {
            content
        }
    }
}
