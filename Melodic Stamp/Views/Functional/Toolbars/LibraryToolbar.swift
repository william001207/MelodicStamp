//
//  LibraryToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/28.
//

import Defaults
import SwiftUI

struct LibraryToolbar: View {
    @Environment(PlayerModel.self) private var player

    @Default(.asksForPlaylistInformation) private var asksForPlaylistInformation

    @State private var shouldWaitForPresentation: Bool = false
    @State private var isPlaylistSegmentsSheetPresented: Bool = false

    var body: some View {
        @Bindable var player = player

        if !player.playlist.mode.isCanonical || shouldWaitForPresentation {
            Button {
                shouldWaitForPresentation = asksForPlaylistInformation
                Task.detached {
                    await player.makePlaylistCanonical()
                }
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .trayFullFill)
                        .imageScale(.small)

                    Text("Add to Library")
                }
            }
            .disabled(player.playlist.isEmpty || player.playlist.mode.isCanonical)
            .onChange(of: player.playlist.mode) { _, newValue in
                guard newValue.isCanonical, asksForPlaylistInformation else { return }
                isPlaylistSegmentsSheetPresented = true
            }
            .sheet(isPresented: $isPlaylistSegmentsSheetPresented) {
                shouldWaitForPresentation = false
            } content: {
                PlaylistMetadataView(playlist: player.playlist, segments: $player.playlistSegments)
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
    }
}
