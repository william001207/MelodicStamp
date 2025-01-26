//
//  UnsavedChangesPresentation.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

struct UnsavedChangesPresentation<Parent>: View where Parent: View {
    @Environment(PlayerModel.self) private var player

    @Binding var isPresented: Bool
    var window: NSWindow?
    @ViewBuilder var parent: () -> Parent

    @State private var windowShouldForceClose: Bool = false
    @State private var isSheetPresented: Bool = false

    var body: some View {
        parent()
            .background(MakeCloseDelegated(shouldClose: windowShouldClose) { shouldClose in
                if shouldClose {
                    player.stop()
                } else {
                    isPresented = true
                }
            })
            .alert("Unsaved Changes", isPresented: $isPresented) {
                alertContent()
            }
            .sheet(isPresented: $isSheetPresented) {
                sheetContent()
            }
    }

    private var modifiedMetadatas: [Metadata] {
        player.metadatas.filter(\.isModified)
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
                    isPresented = false
                    isSheetPresented = true
                }
            } else {
                Button("Save and Close") {
                    player.writeAll {
                        forceClose()
                    }
                }
            }

            closeAnywayButton()
        }

        Button("Cancel", role: .cancel) {
            isPresented = false
        }
    }

    @ViewBuilder private func sheetContent() -> some View {
        ModifiedMetadataList()
            .frame(minWidth: 500, minHeight: 280)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Cancel", role: .cancel) {
                        isSheetPresented = false
                    }

                    Text("Unsaved Changes")
                        .font(.headline)

                    Spacer()

                    if modifiedFineMetadatas.isEmpty, !modifiedMetadatas.isEmpty {
                        Button("Close", role: .destructive) {
                            forceClose()
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: [])
                    } else {
                        closeAnywayButton()
                            .buttonStyle(.borderedProminent)
                            .tint(.red)

                        Button("Save All and Close") {
                            player.writeAll {
                                if modifiedMetadatas.isEmpty {
                                    forceClose()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
                .padding()
                .background(.regularMaterial)
            }
            .presentationSizing(.fitted)
    }

    @ViewBuilder private func closeAnywayButton() -> some View {
        Button("Close Anyway", role: .destructive) {
            forceClose()
        }
    }

    private func forceClose() {
        windowShouldForceClose = true
        DispatchQueue.main.async {
            window?.close()
        }
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
