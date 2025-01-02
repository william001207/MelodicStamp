//
//  AliveProgressViewStyle.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/1.
//

import SwiftUI

struct AliveProgressViewStyle: ProgressViewStyle {
    var lineWidth: CGFloat = 8

    @State private var circleSize: CGSize = .zero

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = fractionCompleted(configuration)

        ZStack {
            let shadowRadius = max(0, fractionCompleted * 2 - 1) * lineWidth / 2

            Circle()
                .trim(from: fractionCompleted / 2, to: fractionCompleted)
                .stroke(.tint, lineWidth: lineWidth)
                .background(alignment: .center) {
                    knob(at: fractionCompleted, shadowRadius: shadowRadius)
                }

            Circle()
                .trim(from: 0, to: fractionCompleted / 2)
                .stroke(.tint, lineWidth: lineWidth)
                .background(alignment: .center) {
                    knob(at: 0, shadowRadius: shadowRadius)
                }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            circleSize = newValue
        }
        .rotationEffect(.degrees(-90), anchor: .center)
        .compositingGroup()
    }

    private var circleRadius: CGFloat {
        min(circleSize.width, circleSize.height) / 2
    }

    @ViewBuilder private func knob(
        at fraction: CGFloat,
        shadowRadius: CGFloat = .zero
    ) -> some View {
        let diameter = circleRadius * 2 + lineWidth

        Rectangle()
            .foregroundStyle(.clear)
            .frame(width: diameter, height: diameter)
            .overlay(alignment: .trailing) {
                Circle()
                    .foregroundStyle(.tint)
                    .frame(width: lineWidth, height: lineWidth)
                    .shadow(color: .black.opacity(0.45), radius: shadowRadius)
            }
            .rotationEffect(
                .radians(fraction * 2 * CGFloat.pi),
                anchor: .center
            )
    }

    private func fractionCompleted(_ configuration: Configuration) -> CGFloat {
        configuration.fractionCompleted ?? .zero
    }
}

extension ProgressViewStyle where Self == AliveProgressViewStyle {
    static func alive(lineWidth: CGFloat = 8) -> Self {
        .init(lineWidth: lineWidth)
    }

    static var alive: Self { .alive() }
}

#Preview {
    @Previewable @State var progress: CGFloat = 0.5

    VStack {
        ProgressView(value: progress)
            .progressViewStyle(.alive(lineWidth: 20))
            .frame(width: 100)

        Slider(value: $progress, in: 0...1)
    }
    .padding()
}
