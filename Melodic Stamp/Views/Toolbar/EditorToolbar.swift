//
//  EditorToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct EditorToolbar: View {
    @Bindable var metadataEditor: MetadataEditorModel

    var body: some View {
        Button {
            metadataEditor.writeAll()
        } label: {
            ToolbarLabel {
                switch metadataEditor.state {
                case .fine:
                    Image(systemSymbol: .trayAndArrowDownFill)
                        .imageScale(.small)

                    Text("Save")
                case .partiallySaving, .saving:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)

                    Text("Saving…")
                }
            }
        }
        .disabled(!metadataEditor.state.isEditable)

        Button {
            metadataEditor.restoreAll()
        } label: {
            ToolbarLabel {
                Image(systemSymbol: .arrowUturnLeft)
                    .imageScale(.small)

                Text("Revert")
            }
            .foregroundStyle(.red)
        }
    }
}
