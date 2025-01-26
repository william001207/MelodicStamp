//
//  View+Animations.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

extension View {
    @ViewBuilder func wiggleAnimation(
        _ trigger: some Equatable,
        count: Int = 4,
        size: CGSize = .init(width: 5, height: 0),
        delay: TimeInterval = .zero
    ) -> some View {
        let phases: [CGFloat] = [0.0] + Array(alternating: 1.0, count: count) + [0.0]
        phaseAnimator(phases, trigger: trigger) { content, value in
            content
                .offset(x: value * size.width, y: value * size.height)
        } animation: { value in
            if abs(value) > 0 {
                .easeOut(duration: 0.1).delay(delay)
            } else {
                .easeIn(duration: 0.1).delay(delay)
            }
        }
    }

    @ViewBuilder func bounceAnimation(
        _ trigger: some Equatable,
        scale: CGSize = .init(width: 1.1, height: 1.1),
        anchor: UnitPoint = .center,
        duration: Double = 0.5,
        delay: TimeInterval = .zero
    ) -> some View {
        phaseAnimator([false, true], trigger: trigger) { content, value in
            content
                .scaleEffect(value ? scale : .init(width: 1, height: 1), anchor: anchor)
        } animation: { value in
            if value {
                .smooth(duration: duration).delay(delay)
            } else {
                .bouncy(duration: duration, extraBounce: 0.25).delay(delay)
            }
        }
    }
}

#Preview("Wiggle Animation") {
    @Previewable @State var trigger = false

    VStack {
        Image(systemSymbol: .appleLogo)
            .font(.largeTitle)
            .foregroundStyle(.tint)
            .wiggleAnimation(trigger)
            .padding()

        Button("Trigger") {
            trigger.toggle()
        }
    }
    .padding()
}

#Preview("Bounce Animation") {
    @Previewable @State var trigger = false

    VStack {
        Image(systemSymbol: .appleLogo)
            .font(.largeTitle)
            .foregroundStyle(.tint)
            .bounceAnimation(trigger, scale: .init(width: 2, height: 2))
            .padding()

        Button("Trigger") {
            trigger.toggle()
        }
    }
    .padding()
}
