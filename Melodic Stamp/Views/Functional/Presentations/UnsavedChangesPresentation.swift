//
//  UnsavedChangesPresentation.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/2/1.
//

import SwiftUI

struct UnsavedChangesPresentation: View {
    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(PresentationManagerModel.self) private var presentationManager
    @Environment(PlaylistModel.self) private var playlist
    @Environment(PlayerModel.self) private var player

    @Environment(\.appDelegate) private var appDelegate

    var window: NSWindow?

    var body: some View {
        @Bindable var presentationManager = presentationManager

        if !modifiedMetadataSet.isEmpty {
            Color.clear
                .alert("Unsaved Changes", isPresented: $presentationManager.isUnsavedChangesAlertPresented) {
                    alertContent()
                } message: {
                    alertMessage()
                }
                .sheet(isPresented: $presentationManager.isUnsavedChangesSheetPresented) {
                    sheetContent()
                }
        } else {
            Color.clear
                .onChange(of: presentationManager.state) { _, newValue in
                    guard newValue == .unsavedChangesAlert else { return }
                    presentationManager.nextStage()
                }
                .onChange(of: presentationManager.state) { _, newValue in
                    guard newValue == .unsavedChangesSheet else { return }
                    presentationManager.nextStage()
                }
        }
    }

    private var modifiedMetadataSet: [Metadata] {
        playlist.metadataSet.filter(\.isModified)
    }

    private var modifiedFineMetadataSet: [Metadata] {
        modifiedMetadataSet.filter(\.state.isFine)
    }

    @ViewBuilder private func alertContent() -> some View {
        if modifiedFineMetadataSet.isEmpty, !modifiedMetadataSet.isEmpty {
            Button("Close") {
                close()
            }
        } else {
            if modifiedMetadataSet.count > 1 {
                Button("Save…") {
                    presentationManager.nextStep()
                }
            } else {
                Button("Save and Close") {
                    playlist.writeAll {
                        if modifiedMetadataSet.isEmpty {
                            close()
                        }
                    }
                }
            }

            closeAnywayButton()
        }

        cancelButton()
    }

    @ViewBuilder private func alertMessage() -> some View {
        Text("Review your changes before closing.")
    }

    @ViewBuilder private func sheetContent() -> some View {
        ModifiedMetadataList()
            .frame(minWidth: 500, minHeight: 280)
            .presentationAttachmentBar(edge: .bottom) {
                Group {
                    cancelButton()
                        .buttonStyle(.alive(enabledStyle: .secondary, hoveringStyle: .tertiary))

                    Divider()

                    Text("Unsaved Changes")
                        .bold()

                    Spacer()

                    if modifiedFineMetadataSet.isEmpty, !modifiedMetadataSet.isEmpty {
                        Button("Close", role: .destructive) {
                            close()
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: [])
                    } else {
                        closeAnywayButton()
                            .foregroundStyle(.red)

                        Button("Save All and Close") {
                            playlist.writeAll {
                                if modifiedMetadataSet.isEmpty {
                                    close()
                                }
                            }
                        }
                        .foregroundStyle(.tint)
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
                .buttonStyle(.alive)
            }
            .presentationSizing(.form)
    }

    @ViewBuilder private func closeAnywayButton() -> some View {
        Button("Close Anyway", role: .destructive) {
            close()
        }
    }

    @ViewBuilder private func cancelButton() -> some View {
        Button("Cancel", role: .cancel) {
            cancel()
        }
    }

    private func close() {
        presentationManager.state = .idle
        windowManager.state = .willClose
    }

    private func cancel() {
        presentationManager.state = .idle
        windowManager.state = .closeCanceled
    }
}
