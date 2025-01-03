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
        Button {} label: {
            Image(systemSymbol: .pencilLine)
            Text("Edit")
        }
    }
}
