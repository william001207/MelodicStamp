//
//  VibrantBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct VibrantBackgroundView: View {
    var state: NSVisualEffectView.State = .followsWindowActiveState
    var isEmphasized: Bool = true

    var body: some View {
        VisualEffectView(material: .menu, blendingMode: .behindWindow, state: state, isEmphasized: isEmphasized)
            .overlay(.thinMaterial)
    }
}

#Preview {
    VibrantBackgroundView()
}
