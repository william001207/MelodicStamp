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
            
            switch mode {
            case .single:
                Text("Single Loop")
            case .sequential:
                Text("Sequential")
            case .loop:
                Text("Sequential Loop")
            case .shuffle:
                Text("Shuffle")
            }
        }
        .tag(mode)
    }
}

#Preview {
    ForEach(PlaybackMode.allCases) { mode in
        PlaybackModeView(mode: mode)
    }
}
