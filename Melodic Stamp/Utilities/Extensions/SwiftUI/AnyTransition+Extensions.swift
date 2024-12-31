//
//  AnyTransition+Extensions.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

extension AnyTransition {
    static func blurTransition(radius: CGFloat) -> AnyTransition {
        .modifier(
            active: BlurModifier(radius: radius),
            identity: BlurModifier(radius: 0)
        )
    }
}

struct BlurModifier: ViewModifier {
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
    }
}
