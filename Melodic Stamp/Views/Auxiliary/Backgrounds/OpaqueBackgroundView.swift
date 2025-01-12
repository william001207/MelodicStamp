//
//  OpaqueBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct OpaqueBackgroundView: View {
    var body: some View {
        VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
    }
}

#Preview {
    OpaqueBackgroundView()
}
