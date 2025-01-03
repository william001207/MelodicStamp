//
//  LyricsToolbar.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/3.
//

import SwiftUI

struct LyricsToolbar: View {
    @Environment(MetadataEditorModel.self) private var metadataEditor
    
    @State private var isEditorSheetPresented: Bool = false

    var body: some View {
        Button {
            isEditorSheetPresented.toggle()
        } label: {
            Image(systemSymbol: .pencilLine)
            Text("Edit")
        }
        .sheet(isPresented: $isEditorSheetPresented) {
            LyricsEditorSheet()
        }
    }
}
