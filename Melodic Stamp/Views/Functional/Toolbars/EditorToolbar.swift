//
//  EditorToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct EditorToolbar: ToolbarContent {
    @Environment(MetadataEditorModel.self) private var metadataEditor

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ControlGroup {
                Button {
                    metadataEditor.writeAll()
                } label: {
                    Label {
                        switch metadataEditor.state {
                        case .saving:
                            Text("Saving…")
                        default:
                            Text("Save")
                        }
                    } icon: {
                        switch metadataEditor.state {
                        case .fine, []:
                            Image(systemSymbol: .trayAndArrowDownFill)
                        default:
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
                .disabled(metadataEditor.state.isSaving || !metadataEditor.isModified)

                Button {
                    metadataEditor.updateAll()
                } label: {
                    Label("Load", systemSymbol: .trayAndArrowUpFill)
                }
                .disabled(!metadataEditor.hasMetadata)
            } label: {
                switch metadataEditor.state {
                case .saving:
                    Text("Saving…")
                default:
                    Text("Save/Load")
                }
            }
        }

        ToolbarItem(placement: .destructiveAction) {
            Button {
                metadataEditor.restoreAll()
            } label: {
                Label("Restore", systemSymbol: .arrowUturnLeft)
            }
            .disabled(!metadataEditor.isModified)
        }
    }
}
