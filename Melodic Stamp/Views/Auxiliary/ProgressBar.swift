//
//  ProgressBar.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI

struct ProportionalWidthEffect: GeometryEffect {
    var animatableData: CGFloat {
        get { proportion }
        set { proportion = newValue }
    }

    var proportion: CGFloat = 0

    func effectValue(size _: CGSize) -> ProjectionTransform {
        .init(.init(scaleX: max(.leastNonzeroMagnitude, min(1, proportion)), y: 1))
    }
}

struct ProgressBar: View {
    enum UpdateType {
        case literal
        case offset
    }

    enum InteractionState {
        case receiving
        case updating
        case propagating
    }

    @Environment(\.isEnabled) private var isEnabled

    @Binding var value: CGFloat
    var total: CGFloat = 1
    @Binding var isActive: Bool
    var isDelegated: Bool = false

    var shrinkFactor: CGFloat = 0.6
    var overshoot: CGFloat = 16
    var externalOvershootSign: FloatingPointSign?

    var onPercentageChange: (CGFloat, CGFloat) -> () = { _, _ in }
    var onOvershootOffsetChange: (CGFloat, CGFloat) -> () = { _, _ in }

    @State private var interactionState: InteractionState = .receiving
    @State private var percentage: CGFloat = .zero
    @State private var percentageOrigin: CGFloat = .zero

    @State private var containerSize: CGSize = .zero
    @State private var overshootPercentage: CGFloat = .zero

    var body: some View {
        ZStack {
            Group {
                Rectangle()
                    .foregroundStyle(.background)

                if isEnabled {
                    Rectangle()
                        .mask(alignment: .leading) {
                            Color.white
                                .modifier(ProportionalWidthEffect(proportion: percentage))
                        }
                }
            }
            .clipShape(.capsule)
            .frame(height: isActive ? containerSize.height : containerSize.height * shrinkFactor)
            .animation(.smooth, value: isActive)
            .animation(.smooth(duration: 0.35), value: percentage)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            containerSize = size
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                guard isEnabled else { return }

                switch interactionState {
                case .receiving:
                    // start dragging
                    isActive = true
                    interactionState = .updating
                    update(percentage: gesture.location.x / containerSize.width)
                case .updating:
                    // update dragging
                    update(
                        percentage: gesture.translation.width / containerSize.width,
                        type: .offset
                    )
                case .propagating:
                    break
                }

                tryOvershoot(offset: gesture.location.x)
            }
            .onEnded { gesture in
                guard isEnabled else { return }

                isActive = false
                interactionState = isDelegated ? .propagating : .receiving
                update(
                    percentage: gesture.translation.width / containerSize.width,
                    type: .offset
                )
                tryOvershoot(offset: 0)
            })

        .scaleEffect(.init(width: abs(overshootPercentage * overshootFactor) + 1, height: 1), anchor: .leading)
        .offset(x: overshootOffset)
        .animation(.default, value: overshootOffset)
        .animation(.default, value: isEnabled)
        .onChange(of: overshootOffset, initial: true, onOvershootOffsetChange)
        .onChange(of: percentage, initial: true, onPercentageChange)
        .onChange(of: value, initial: true) { _, newValue in
            if isDelegated {
                switch interactionState {
                case .receiving:
                    percentage = max(0, min(1, newValue / total))
                default:
                    break
                }
            } else {
                percentage = max(0, min(1, newValue / total))
            }
        }
        .onChange(of: percentage) { _, newValue in
            syncDelegate(percentage: newValue)
        }
        .onChange(of: interactionState) { _, _ in
            syncDelegate(percentage: percentage)
        }
    }

    private var overshootFactor: CGFloat {
        overshoot / containerSize.width
    }

    private var overshootOffset: CGFloat {
        if let externalOvershootSign {
            switch externalOvershootSign {
            case .plus:
                overshoot
            case .minus:
                -overshoot
            }
        } else {
            if overshootPercentage >= 0 {
                overshootPercentage * overshoot * 0.1
            } else {
                overshootPercentage * overshoot * 1.1
            }
        }
    }

    private func update(percentage: CGFloat, type: UpdateType = .literal) {
        switch type {
        case .literal:
            self.percentage = max(0, min(1, percentage))
            percentageOrigin = self.percentage
        case .offset:
            self.percentage = max(0, min(1, percentageOrigin + percentage))
        }
    }

    private func tryOvershoot(offset: CGFloat) {
        if offset < 0 {
            overshootPercentage = max(tanh(offset * .pi), offset / overshoot)
        } else if offset > containerSize.width {
            let offset = offset - containerSize.width
            overshootPercentage = min(tanh(offset * .pi), offset / overshoot)
        } else {
            overshootPercentage = 0
        }
    }

    private func syncDelegate(percentage: CGFloat) {
        if isDelegated {
            switch interactionState {
            case .propagating:
                interactionState = .receiving

                guard percentage != value / total else { return }
                value = total * percentage
            default:
                break
            }
        } else {
            guard percentage != value / total else { return }
            value = total * percentage
        }
    }
}

#Preview {
    @Previewable @State var value: CGFloat = 0.42
    @Previewable @State var isActive = false

    ProgressBar(value: $value, isActive: $isActive)
        .frame(width: 300, height: 12)
        .padding()
        .backgroundStyle(.quinary)

    ProgressBar(value: $value, isActive: $isActive, isDelegated: true)
        .frame(width: 300, height: 12)
        .padding()
        .foregroundStyle(.tint)
        .backgroundStyle(.quinary)
}
