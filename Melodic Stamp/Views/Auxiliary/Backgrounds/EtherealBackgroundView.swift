//
//  EtherealBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct EtherealBackgroundView: View {
    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
    }
}

#Preview {
    EtherealBackgroundView()
}
