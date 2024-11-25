//
//  EditorToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI
import SFSafeSymbols

struct EditorToolbar: View {
    @Bindable var metadataEditor: MetadataEditorModel
    
    var body: some View {
        Group {
            Button {
                metadataEditor.writeAll()
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .trayAndArrowDownFill)
                        .imageScale(.small)
                    
                    Text("Save")
                }
            }
            
            Button {
                metadataEditor.revertAll()
            } label: {
                ToolbarLabel {
                    Image(systemSymbol: .clockArrowCirclepath)
                        .imageScale(.small)
                    
                    Text("Revert")
                }
                .foregroundStyle(.red)
            }
        }
        .background(.thinMaterial)
        .clipShape(.buttonBorder)
    }
}
