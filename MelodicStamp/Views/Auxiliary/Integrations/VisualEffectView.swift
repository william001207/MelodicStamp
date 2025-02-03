//
//  VisualEffectView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI

// SwiftUI view for NSVisualEffect
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State = .followsWindowActiveState
    var isEmphasized: Bool = true

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()

        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = state
        visualEffectView.isEmphasized = isEmphasized

        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context _: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
