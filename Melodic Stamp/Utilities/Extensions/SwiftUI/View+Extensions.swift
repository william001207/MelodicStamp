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

    @ViewBuilder func gradientBackground(_ color: Color = .accent) -> some View {
        modifier(GradientBackgroundModifier(color: color))
    }

    @ViewBuilder func hoverableBackground(isExplicitlyVisible: Bool? = nil) -> some View {
        modifier(HoverableBackgroundModifier(isExplicitlyVisible: isExplicitlyVisible))
    }

    @ViewBuilder func continuousRippleEffect(lerpFactor: CGFloat = 0.2) -> some View {
        modifier(ContinuousRippleEffectModifier(lerpFactor: lerpFactor))
    }

    @ViewBuilder func motionCard(
        scale: CGFloat = 1.02, angle: Angle = .degrees(3.5),
        shadowColor: Color = .black.opacity(0.1), shadowRadius: CGFloat = 10,
        glintColor: Color = .white.opacity(0.1), glintRadius: CGFloat = 50
    ) -> some View {
        modifier(MotionCardModifier(
            scale: scale, angle: angle,
            shadowColor: shadowColor, shadowRadius: shadowRadius,
            glintColor: glintColor, glintRadius: glintRadius
        ))
    }

    @ViewBuilder func presentationAttachmentBar(
        edge: VerticalEdge, material: Material = .regular,
        @ViewBuilder attachment: @escaping () -> some View
    ) -> some View {
        modifier(PresentationAttachmentBarModifier(edge: edge, material: material, attachment: attachment) {
            EmptyView()
        })
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

// https://gist.github.com/joelekstrom/91dad79ebdba409556dce663d28e8297
extension View {
    /// Adds a double click handler this view.
    ///
    /// In order to make listeners like ``onHover`` work, this listener must precede them.
    ///
    /// ```
    /// Text("Hello")
    ///     .onDoubleClick { print("Double click detected") }
    /// ```
    ///
    /// - Parameters:
    ///   - handler: Block invoked when a double click is detected
    func onDoubleClick(handler: @escaping () -> ()) -> some View {
        modifier(DoubleClickHandler(handler: handler))
    }
}
