//
//  PlaybackModeView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

struct PlaybackModeView: View {
    var mode: PlaybackMode

    var body: some View {
        HStack {
            mode.image

            Text(Self.name(of: mode))
        }
        .tag(mode)
    }

    static func name(of mode: PlaybackMode) -> String {
        switch mode {
        case .sequential:
            .init(localized: "Sequential")
        case .loop:
            .init(localized: "Sequential Loop")
        case .shuffle:
            .init(localized: "Shuffle")
        }
    }
}

#Preview {
    ForEach(PlaybackMode.allCases) { mode in
        PlaybackModeView(mode: mode)
    }
}
