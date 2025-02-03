//
//  OpaqueBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct OpaqueBackgroundView: View {
    var state: NSVisualEffectView.State = .followsWindowActiveState
    var isEmphasized: Bool = true

    var body: some View {
        VisualEffectView(material: .contentBackground, blendingMode: .behindWindow, state: state, isEmphasized: isEmphasized)
    }
}

#Preview {
    OpaqueBackgroundView()
}
