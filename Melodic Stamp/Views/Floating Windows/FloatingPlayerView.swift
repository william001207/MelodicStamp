//
//  FloatingPlayerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayerView: View {
    var body: some View {
        PlayerView()
            .background {
                // Do not use `.background(:)` otherwise causing temporary vibrancy lost
                VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
            }
            .frame(height: 100)
            .clipShape(.rect(cornerRadius: 25))
    }
}
