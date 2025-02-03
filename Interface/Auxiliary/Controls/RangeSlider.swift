//
//  RangeSlider.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import SwiftUI

struct RangeSlider<V>: View where V: Strideable & Comparable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @Binding var range: ClosedRange<V>
    var availableRange: ClosedRange<V>
    var step: V.Stride

    @State private var size: CGSize = .zero
    @State private var isLowerRangeHovering: Bool = false
    @State private var isUpperRangeHovering: Bool = false

    init(
        range: Binding<ClosedRange<V>>,
        in availableRange: ClosedRange<V>,
        step: V.Stride = 1
    ) {
        self._range = range
        self.availableRange = availableRange
        self.step = step
    }

    var body: some View {
        ZStack(alignment: .center) {
            if hasLowerPart {
                HStack(spacing: 0) {
                    Slider(value: lowerValueBinding, in: availableLowerRange, step: step)
                        .frame(width: compensatedWidth(lowerScale))
                        .mask(alignment: .trailing) {
                            HStack(spacing: 0) {
                                Color.white

                                Color.clear
                                    .frame(width: compensatedWidth(centerScale / 2, postCompensated: false))
                            }
                            .padding(hasUpperPart ? .all.subtracting(.trailing) : .all, -1)
                        }

                    Spacer(minLength: 0)
                }
                .zIndex(isLowerRangeHovering ? 1 : 0)
            }

            if hasUpperPart {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Slider(value: upperValueBinding, in: availableUpperRange, step: step)
                        .frame(width: compensatedWidth(upperScale))
                        .mask(alignment: .leading) {
                            HStack(spacing: 0) {
                                Color.clear
                                    .frame(width: compensatedWidth(centerScale / 2, postCompensated: false))

                                Color.white
                            }
                            .padding(hasLowerPart ? .all.subtracting(.leading) : .all, -1)
                        }
                }
                .zIndex(isUpperRangeHovering ? 1 : 0)
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            size = newValue
        }
        .onContinuousHover { phase in
            switch phase {
            case let .active(point):
                let threshold = compensatedWidth(lowerScale - centerScale / 2, postCompensated: false)
                isLowerRangeHovering = point.x <= threshold
                isUpperRangeHovering = point.x > threshold
            case .ended:
                isLowerRangeHovering = false
                isUpperRangeHovering = false
            }
        }
    }

    private var edgeCompensation: CGFloat {
        rangeSpan > .zero ? 3 : -0.5
    }

    private var hasLowerPart: Bool {
        rangeSpan > .zero || range.lowerBound > availableRange.lowerBound
    }

    private var hasUpperPart: Bool {
        rangeSpan > .zero || range.upperBound < availableRange.upperBound
    }

    private var lowerValueBinding: Binding<V> {
        Binding {
            max(availableRange.lowerBound, range.lowerBound)
        } set: { newValue in
            range = max(availableRange.lowerBound, newValue)...range.upperBound
        }
    }

    private var upperValueBinding: Binding<V> {
        Binding {
            min(availableRange.upperBound, range.upperBound)
        } set: { newValue in
            range = range.lowerBound...min(availableRange.upperBound, newValue)
        }
    }

    private var availableLowerRange: ClosedRange<V> {
        availableRange.lowerBound...range.upperBound
    }

    private var availableUpperRange: ClosedRange<V> {
        range.lowerBound...availableRange.upperBound
    }

    private var rangeSpan: V.Stride {
        range.lowerBound.distance(to: range.upperBound)
    }

    private var availableRangeSpan: V.Stride {
        availableRange.lowerBound.distance(to: availableRange.upperBound)
    }

    private var availableLowerRangeSpan: V.Stride {
        availableLowerRange.lowerBound.distance(to: availableLowerRange.upperBound)
    }

    private var availableUpperRangeSpan: V.Stride {
        availableUpperRange.lowerBound.distance(to: availableUpperRange.upperBound)
    }

    private var lowerScale: CGFloat {
        CGFloat(availableLowerRangeSpan / availableRangeSpan)
    }

    private var upperScale: CGFloat {
        CGFloat(availableUpperRangeSpan / availableRangeSpan)
    }

    private var centerScale: CGFloat {
        CGFloat(rangeSpan / availableRangeSpan)
    }

    private func compensatedWidth(_ scale: CGFloat, postCompensated: Bool = true) -> CGFloat {
        let postCompensation: CGFloat = (postCompensated ? 2 : 1) * edgeCompensation
        return max(0, min(size.width, (size.width - 2 * edgeCompensation) * scale + postCompensation))
    }
}

#Preview {
    @Previewable @State var range: ClosedRange<CGFloat> = 2...3

    RangeSlider(range: $range, in: 0...10)
        .padding()
        .background(.blue)
}
