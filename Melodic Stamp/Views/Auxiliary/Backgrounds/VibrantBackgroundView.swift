//
//  VibrantBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct VibrantBackgroundView: View {
    var body: some View {
        VisualEffectView(material: .headerView, blendingMode: .behindWindow)
    }
}

#Preview {
    VibrantBackgroundView()
}
