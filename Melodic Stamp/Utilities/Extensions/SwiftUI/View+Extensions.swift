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
}

extension View {
    @ViewBuilder func aliveHighlight(_ isHighlighted: Bool, cornerRadius: CGFloat = 8) -> some View {
        modifier(AliveHighlightViewModifier(isHighlighted: isHighlighted, cornerRadius: cornerRadius))
    }

    @ViewBuilder func gradientBackground(_ color: Color = .accent) -> some View {
        modifier(GradientBackgroundModifier(color: color))
    }

    @ViewBuilder func hoverableBackground(isExplicitlyVisible: Bool? = nil) -> some View {
        modifier(HoverableBackgroundModifier(isExplicitlyVisible: isExplicitlyVisible))
    }

    @ViewBuilder func dragEffect(alpha: CGFloat = 0.2) -> some View {
        modifier(DragEffectModifier(alpha: alpha))
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
