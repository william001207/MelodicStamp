//
//  EmptyMusicNoteView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SFSafeSymbols
import SwiftUI

struct EmptyMusicNoteView: View {
    var systemSymbol: SFSymbol = .musicNote

    var body: some View {
        Image(systemSymbol: systemSymbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 32)
            .foregroundStyle(.placeholder)
    }
}
