//
//  HoverableBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct HoverableBackgroundView<Content>: View where Content: View {
    var isExplicitlyVisible: Bool?
    @ViewBuilder var content: () -> Content

    @State private var isHovering: Bool = false

    var body: some View {
        content()
            .background {
                Rectangle()
                    .foregroundStyle(.background)
                    .opacity(isVisible ? 0.1 : 0)
                    .blendMode(.multiply)
            }
            .onHover { hover in
                isHovering = hover
            }
            .animation(.smooth(duration: 0.25), value: isVisible)
    }

    private var isVisible: Bool {
        if let isExplicitlyVisible {
            isExplicitlyVisible
        } else {
            isHovering
        }
    }
}

struct HoverableBackgroundModifier: ViewModifier {
    var isExplicitlyVisible: Bool?

    func body(content: Content) -> some View {
        HoverableBackgroundView(isExplicitlyVisible: isExplicitlyVisible) {
            content
        }
    }
}
