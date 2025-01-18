//
//  PlaybackModeView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

struct PlaybackModeView: View {
    var mode: PlaybackMode

    var body: some View {
        HStack {
            Image(systemSymbol: mode.systemSymbol)

            Text(Self.name(of: mode))
        }
        .tag(mode)
    }

    static func name(of mode: PlaybackMode) -> String {
        switch mode {
        case .sequential:
            String(localized: "Sequential")
        case .loop:
            String(localized: "Sequential Loop")
        case .shuffle:
            String(localized: "Shuffle")
        }
    }
}

#Preview {
    ForEach(PlaybackMode.allCases) { mode in
        PlaybackModeView(mode: mode)
    }
}
