//
//  EmptyMusicNoteView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct EmptyMusicNoteView: View {
    var body: some View {
        Image(systemSymbol: .musicNote)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 32)
            .foregroundStyle(.placeholder)
    }
}
