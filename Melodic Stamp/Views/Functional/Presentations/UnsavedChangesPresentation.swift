//
//  UnsavedChangesPresentation.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

struct UnsavedChangesPresentation<Parent>: View where Parent: View {
    @Environment(PlayerModel.self) private var player

    @Environment(\.appDelegate) private var appDelegate

    @Binding var isPresented: Bool
    var window: NSWindow?
    @ViewBuilder var parent: () -> Parent

    @State private var windowShouldForceClose: Bool = false
    @State private var isSheetPresented: Bool = false

    var body: some View {
        parent()
            .background(MakeCloseDelegated(shouldClose: windowShouldClose) { window, shouldClose in
                if shouldClose {
                    player.stop()
                    appDelegate?.destroy(window: window)
                } else {
                    isPresented = true
                    appDelegate?.suspend(window: window)
                }
            })
            .alert("Unsaved Changes", isPresented: $isPresented) {
                alertContent()
            } message: {
                alertMessage()
            }
            .sheet(isPresented: $isSheetPresented) {
                sheetContent()
            }
    }

    private var modifiedMetadatas: [Metadata] {
        player.metadataSet.filter(\.isModified)
    }

    private var modifiedFineMetadatas: [Metadata] {
        modifiedMetadatas.filter(\.state.isFine)
    }

    private var windowShouldClose: Bool {
        windowShouldForceClose || modifiedMetadatas.isEmpty
    }

    @ViewBuilder private func alertContent() -> some View {
        if modifiedFineMetadatas.isEmpty, !modifiedMetadatas.isEmpty {
            Button("Close") {
                forceClose()
            }
        } else {
            if modifiedMetadatas.count > 1 {
                Button("Save…") {
                    isSheetPresented = true
                }
            } else {
                Button("Save and Close") {
                    player.writeAll {
                        if modifiedMetadatas.isEmpty {
                            forceClose()
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

                    if modifiedFineMetadatas.isEmpty, !modifiedMetadatas.isEmpty {
                        Button("Close", role: .destructive) {
                            forceClose()
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: [])
                    } else {
                        closeAnywayButton()
                            .foregroundStyle(.red)

                        Button("Save All and Close") {
                            player.writeAll {
                                if modifiedMetadatas.isEmpty {
                                    forceClose()
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
            forceClose()
        }
    }

    @ViewBuilder private func cancelButton() -> some View {
        Button("Cancel", role: .cancel) {
            cancel()
        }
    }

    private func forceClose() {
        windowShouldForceClose = true
        DispatchQueue.main.async {
            window?.performClose(nil)
        }
    }

    private func cancel() {
        isPresented = false
        isSheetPresented = false
        appDelegate?.resumeWindowSuspension()
    }
}

struct UnsavedChangesModifier: ViewModifier {
    @Binding var isPresented: Bool
    var window: NSWindow?

    func body(content: Content) -> some View {
        UnsavedChangesPresentation(
            isPresented: $isPresented, window: window
        ) {
            content
        }
    }
}
