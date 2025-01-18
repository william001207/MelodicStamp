//
//  FloatingPlayerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayerView: View {
    @Namespace private var namespace

    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)

            PlayerView(namespace: namespace)
        }
        .frame(height: 100)
        .clipShape(.rect(cornerRadius: 25))
    }
}
