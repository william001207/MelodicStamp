//
//  View+Extensions.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import Morphed
import SwiftUI

extension View {
    func observeAnimation<Value: VectorArithmetic>(for observedValue: Value, onChange: ((Value) -> ())? = nil, onComplete: (() -> ())? = nil) -> some View {
        modifier(AnimationObserverModifier(for: observedValue, onChange: onChange, onComplete: onComplete))
    }

    @ViewBuilder func contentOffset(_ offset: Binding<CGFloat>, in name: AnyHashable) -> some View {
        modifier(ContentOffsetModifier(name: name, offset: offset))
    }
}

extension View {
    @ViewBuilder func aliveHighlight(_ isHighlighted: Bool, cornerRadius: CGFloat = 8) -> some View {
        modifier(AliveHighlightViewModifier(isHighlighted: isHighlighted, cornerRadius: cornerRadius))
    }

    @ViewBuilder func simpleGradient(_ color: Color = .accent) -> some View {
        modifier(SimpleGradientModifier(color: color))
    }

    @ViewBuilder func hoverableBackground(isExplicitlyVisible: Bool? = nil) -> some View {
        modifier(HoverableBackgroundModifier(isExplicitlyVisible: isExplicitlyVisible))
    }

    @ViewBuilder func presentationAttachmentBar(
        edge: VerticalEdge, material: Material = .regular,
        @ViewBuilder attachment: @escaping () -> some View
    ) -> some View {
        modifier(PresentationAttachmentBarModifier(edge: edge, material: material, attachment: attachment) {
            EmptyView()
        })
    }

    // A hack
    @ViewBuilder func expandContextMenuActivationArea() -> some View {
        background(.white.opacity(0.0001))
    }
}

extension View {
    /// A predefined morphed effect for windows with large title bars and floating players.
    @ViewBuilder func morphed(isActive: Bool = true) -> some View {
        morphed(
            insets: .init(bottom: .fixed(length: 64).mirrored), isActive: isActive,
            LinearGradient(
                colors: [.white, .black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
        .morphed(
            insets: .init(top: .fixed(length: 94).mirrored), isActive: isActive,
            LinearGradient(
                colors: [.white, .black],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .ignoresSafeArea()
    }
}
