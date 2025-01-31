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
    @Environment(PlaylistModel.self) private var playlist

    @Environment(\.dismissWindow) private var dismissWindow

    @Default(.asksForPlaylistInformation) private var asksForPlaylistInformation

    @State private var shouldWaitForPresentation: Bool = false
    @State private var isPlaylistSegmentsSheetPresented: Bool = false
    @State private var isPlaylistRemovalAlertPresented: Bool = false

    var body: some View {
        @Bindable var playlist = playlist

        if !playlist.mode.isCanonical || shouldWaitForPresentation {
            Button {
                shouldWaitForPresentation = asksForPlaylistInformation
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
            .onChange(of: playlist.mode) { _, newValue in
                guard newValue.isCanonical, asksForPlaylistInformation else { return }
                isPlaylistSegmentsSheetPresented = true
            }
            .sheet(isPresented: $isPlaylistSegmentsSheetPresented) {
                shouldWaitForPresentation = false
            } content: {
                PlaylistMetadataView()
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, -8)
                    .presentationAttachmentBar(edge: .bottom) {
                        Group {
                            Text("Playlist Information")

                            Spacer()

                            Button {
                                isPlaylistSegmentsSheetPresented = false
                            } label: {
                                Text("Done")
                            }
                            .foregroundStyle(.tint)
                        }
                        .buttonStyle(.alive)
                    }
                    .frame(width: 600)
            }
        }

        if playlist.mode.isCanonical || isPlaylistRemovalAlertPresented {
            Button {
                isPlaylistRemovalAlertPresented = true
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .trashFill)
                        .imageScale(.small)

                    Text("Remove from Library")
                }
                .foregroundStyle(.red)
            }
            .alert("Removing Playlist from Library", isPresented: $isPlaylistRemovalAlertPresented) {
                Button("Proceed", role: .destructive) {
                    library.remove([playlist.playlist])
                    dismissWindow()
                }
            } message: {
                Text("This will permanently delete the corresponding directory.")
            }
        }
    }
}
