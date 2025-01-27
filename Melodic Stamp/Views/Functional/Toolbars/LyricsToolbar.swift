//
//  LyricsToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/3.
//

import Luminare
import SwiftUI

struct LyricsToolbar: View {
    @Environment(MetadataEditorModel.self) private var metadataEditor

    var body: some View {
        LabeledTextEditor(
            entries: metadataEditor[extracting: \.lyrics],
            layout: .button, style: .code
        ) {
            ToolbarImageLabel(systemSymbol: .pencilLine)
                .imageScale(.small)
        } actions: {
            Image(systemSymbol: .info)
                .luminarePopover {
                    Text("""
                    You can use [AMLL TTML Tool](https://steve-xmh.github.io/amll-ttml-tool) to create TTML lyrics through a refined interface.
                    """)
                    .padding()
                }
        }
        .disabled(!metadataEditor.hasMetadata)
    }
}
