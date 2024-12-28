//
//  BouncyScrollView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

enum BouncyScrollViewAnimationState {
    case intermediate
    case pushed
}

enum BouncyScrollViewAlignment {
    case top
    case center
}

enum BouncyScrollViewIndicator {
    case invisible
    case visible(content: AnyView)

    static func visible(@ViewBuilder _ content: @escaping () -> some View) -> Self {
        .visible(content: .init(content()))
    }

    var isVisible: Bool {
        switch self {
        case .visible: true
        case .invisible: false
        }
    }
}

struct BouncyScrollView<Content: View>: View {
    var offset: CGFloat = 50
    var delay: TimeInterval = 0.08
    var bounceDelay: TimeInterval = 0.5

    var range: Range<Int>
    var highlightedRange: Range<Int>
    var alignment: BouncyScrollViewAlignment = .top

    @ViewBuilder var content: (_ index: Int, _ isHighlighted: Bool) -> Content
    var indicator: (_ index: Int, _ isHighlighted: Bool) -> BouncyScrollViewIndicator

    @State private var containerSize: CGSize = .zero
    @State private var animationState: BouncyScrollViewAnimationState = .intermediate
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var scrollOffset: CGFloat = .zero
    @State private var contentOffsets: [Int: CGFloat] = [:]

    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: offset)

            Spacer()
                .frame(height: max(0, compensate))

            LazyVStack(spacing: 0) {
                ForEach(range, id: \.self) { index in
                    let isHighlighted = highlightedRange.contains(index)
                    let delay = delay(at: index)

                    Group {
                        if let offset = contentOffsets[index] {
                            let proportion = proportion(at: index)

                            content(index, isHighlighted)
                                .offset(y: proportion * offset)
                                .background {
                                    if index == highlightedRange.lowerBound {
                                        switch indicator(index, isHighlighted) {
                                        case .invisible:
                                            EmptyView()
                                        case let .visible(content):
                                            content
                                                .opacity(proportion)
                                                .animation(.default, value: proportion)
                                        }
                                    }
                                }
                        } else {
                            content(index, isHighlighted)
                        }
                    }
                    .animation(.spring(bounce: 0.2).delay(delay), value: animationState)
                    .animation(.smooth, value: highlightedRange)
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newValue in
                        contentOffsets.updateValue(newValue.height, forKey: index)
                    }
                }
            }

            Spacer()
                .frame(height: containerSize.height)
        }
        .scrollIndicators(.never)
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: CGPoint.self) { proxy in
            proxy.contentOffset
        } action: { _, newValue in
            guard scrollPosition.isPositionedByUser else { return }
            scrollOffset = newValue.y
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            containerSize = newValue
        }
        .onAppear {
            updateAnimationState()
        }
        .onChange(of: highlightedRange) { _, newValue in
            withAnimation(.bouncy) {
                scrollOffset = fold(until: newValue.lowerBound)
            }
        }
        .onChange(of: highlightedRange) { oldValue, newValue in
            let isLowerBoundChanged = oldValue.lowerBound != newValue.lowerBound

            guard isLowerBoundChanged else { return }
            updateAnimationState()
        }
        .observeAnimation(for: scrollOffset) { value in
            scrollPosition.scrollTo(y: value)
        }
    }

    private var canPauseAnimation: Bool {
        indicator(highlightedRange.lowerBound, true).isVisible && highlightedRange.isEmpty
    }

    private var compensate: CGFloat {
        switch alignment {
        case .top:
            .zero
        case .center:
            if let offset = contentOffsets[highlightedRange.lowerBound] {
                (containerSize.height - offset) / 2
            } else {
                containerSize.height / 2
            }
        }
    }

    private func fold(until index: Int) -> CGFloat {
        let indices = contentOffsets.keys
        let index = if let maxIndex = indices.max() {
            min(index, maxIndex)
        } else { index }

        return contentOffsets
            .filter { $0.key < index }
            .map(\.value)
            .reduce(0, +)
    }

    private func updateAnimationState() {
        animationState = .intermediate
        DispatchQueue.main.asyncAfter(deadline: .now() + bounceDelay) {
            pushAnimation()
        }
    }

    private func pushAnimation() {
        guard !canPauseAnimation else { return }
        animationState = .pushed
    }

    private func proportion(at index: Int) -> CGFloat {
        if index >= highlightedRange.lowerBound {
            switch animationState {
            case .intermediate: 1
            case .pushed: 0
            }
        } else { 0 }
    }

    private func delay(at index: Int) -> CGFloat {
        switch animationState {
        case .intermediate:
            return 0
        case .pushed:
            guard index >= highlightedRange.upperBound else { return 0 }
            return CGFloat(index - highlightedRange.upperBound) * delay
        }
    }
}

#Preview {
    @Previewable @State var highlightedRange: Range<Int> = 0 ..< 1
    @Previewable @State var alignment: BouncyScrollViewAlignment = .top
    let count = 20

    VStack {
        VStack {
            Picker("Alignment", selection: $alignment) {
                Text("Top")
                    .tag(BouncyScrollViewAlignment.top)
                Text("Center")
                    .tag(BouncyScrollViewAlignment.center)
            }
            .pickerStyle(SegmentedPickerStyle())

            HStack {
                let upperBound = highlightedRange.upperBound

                Text("Lower bound: \(highlightedRange.lowerBound)")
                    .fixedSize()
                    .frame(width: 100, alignment: .leading)

                if upperBound > 0 {
                    Slider(
                        value: Binding {
                            Double(highlightedRange.lowerBound)
                        } set: { newValue in
                            let newBound = min(Int(newValue), upperBound)
                            highlightedRange = max(0, newBound) ..< upperBound
                        },
                        in: 0...Double(upperBound),
                        step: 1
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text("\(0)")
                    } maximumValueLabel: {
                        Text("\(upperBound)")
                    }
                    .monospaced()
                } else {
                    Slider(
                        value: .constant(0),
                        in: 0...1,
                        step: 1
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text("\(0)")
                    } maximumValueLabel: {
                        Text("\(0)")
                    }
                    .disabled(true)
                    .monospaced()
                }
            }

            HStack {
                let lowerBound = highlightedRange.lowerBound

                Text("Upper bound: \(highlightedRange.upperBound)")
                    .fixedSize()
                    .frame(width: 100, alignment: .leading)

                if lowerBound < count {
                    Slider(
                        value: Binding {
                            Double(highlightedRange.upperBound)
                        } set: { newValue in
                            let newBound = max(Int(newValue), lowerBound)
                            highlightedRange = lowerBound ..< min(count, newBound)
                        },
                        in: Double(lowerBound)...Double(count),
                        step: 1
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text("\(lowerBound)")
                    } maximumValueLabel: {
                        Text("\(count)")
                    }
                    .monospaced()
                } else {
                    Slider(
                        value: .constant(1),
                        in: 0...1,
                        step: 1
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text("\(count)")
                    } maximumValueLabel: {
                        Text("\(count)")
                    }
                    .disabled(true)
                    .monospaced()
                }
            }
        }
        .padding()

        BouncyScrollView(
            range: 0 ..< count,
            highlightedRange: highlightedRange,
            alignment: alignment
        ) { index, isHighlighted in
            Text("\(index)")
                .font(.title)
                .shadow(radius: 4)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color(
                    hue: Double(index) / Double(count),
                    saturation: 0.75,
                    brightness: 1
                ))
                .opacity(isHighlighted ? 1 : 0.5)
        } indicator: { _, _ in
            .visible {
                HStack {
                    Circle()
                    Circle()
                    Circle()
                }
                .frame(height: 10)
            }
        }
        .border(.foreground)
        .frame(height: 400)
    }
    .frame(width: 400)
}
