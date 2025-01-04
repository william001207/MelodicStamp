//
//  LyricsToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/3.
//

import SwiftUI

struct LyricsToolbar: View {
    @Environment(MetadataEditorModel.self) private var metadataEditor

    var body: some View {
        if metadataEditor.isVisible {
            LabeledTextEditor(
                entries: metadataEditor[extracting: \.lyrics],
                layout: .button
            ) {
                Image(systemSymbol: .pencilLine)
                Text("Edit")
                    .monospaced(false)
            }
            .monospaced()
        }
    }
}
