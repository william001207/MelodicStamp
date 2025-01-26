//
//  EditorToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct EditorToolbar: View {
    @Environment(MetadataEditorModel.self) private var metadataEditor

    var body: some View {
        Button {
            metadataEditor.writeAll()
        } label: {
            ToolbarLabel {
                switch metadataEditor.state {
                case .fine, []:
                    Image(systemSymbol: .trayAndArrowDownFill)
                        .imageScale(.small)
                default:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }

                switch metadataEditor.state {
                case .saving:
                    Text("Saving…")
                default:
                    Text("Save")
                }
            }
        }
        .disabled(metadataEditor.state.isSaving || !metadataEditor.isModified)

        Button {
            metadataEditor.restoreAll()
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .arrowUturnLeft)
                    .imageScale(.small)

                Text("Restore")
            }
            .foregroundStyle(.red)
        }
        .disabled(!metadataEditor.isModified)

        Button {
            metadataEditor.updateAll()
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .arrowUpDoc)
                    .imageScale(.small)

                Text("Reload")
            }
            .foregroundStyle(.tint)
        }
    }
}
