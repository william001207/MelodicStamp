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

    @State private var isInfoPopoverPresented: Bool = false

    var body: some View {
        if metadataEditor.isVisible {
            LabeledTextEditor(
                entries: metadataEditor[extracting: \.lyrics],
                layout: .button
            ) {
                ToolbarLabel {
                    Image(systemSymbol: .pencilLine)
                    Text("Edit")
                }
                .monospaced(false)
            } info: {
                AliveButton {
                    isInfoPopoverPresented.toggle()
                } label: {
                    Image(systemSymbol: .info)
                        .popover(isPresented: $isInfoPopoverPresented) {
                            Text("""
                            You can use [AMLL TTML Tool](https://steve-xmh.github.io/amll-ttml-tool) to create TTML lyrics through a refined interface.
                            """)
                            .padding()
                        }
                }
                .monospaced(false)
            }
            .monospaced()
        }
    }
}
