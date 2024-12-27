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
    case bottom
}

struct BouncyScrollView<Content: View, Indicators: View>: View {
    var offset: CGFloat = 50
    var delay: TimeInterval = 0.08
    var delayBeforePush: TimeInterval = 0.5
    var canPushAnimation: Bool = true

    var range: Range<Int>
    var highlightedRange: Range<Int>
    var alignment: BouncyScrollViewAlignment = .top

    @ViewBuilder var content: (_ index: Int, _ isHighlighted: Bool) -> Content
    @ViewBuilder var indicators: (_ index: Int, _ isHighlighted: Bool) -> Indicators

    @State private var animationState: BouncyScrollViewAnimationState = .intermediate
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var scrollOffset: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    switch alignment {
                    case .top:
                        EmptyView()
                    case .center:
                        Spacer()
                            .frame(height: geometry.size.height / 2.25)
                    case .bottom:
                        Spacer()
                            .frame(height: geometry.size.height)
                    }

                    ForEach(range, id: \.self) { index in
                        let isHighlighted = highlightedRange.contains(index)
                        let proportion = proportion(at: index)
                        let delay = delay(at: index)

                        content(index, isHighlighted)
                            .offset(y: proportion * offset)
                            .animation(.spring(bounce: 0.20).delay(delay), value: animationState)
                            .animation(.smooth, value: highlightedRange)
                            .overlay {
                                if index == highlightedRange.lowerBound {
                                    indicators(index, isHighlighted)
                                        .opacity(proportion)
                                        .animation(.default, value: proportion)
                                }
                            }
                    }

                    Spacer()
                        .frame(height: offset)

                    switch alignment {
                    case .top:
                        Spacer()
                            .frame(height: geometry.size.height)
                    case .center:
                        Spacer()
                            .frame(height: geometry.size.height / 2.25)
                    case .bottom:
                        Spacer()
                            .frame(height: geometry.size.height)
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGPoint.self) { proxy in
                proxy.contentOffset
            } action: { _, newValue in
                guard scrollPosition.isPositionedByUser else { return }
                scrollOffset = newValue.y
            }
            .onChange(of: highlightedRange) { _, newValue in
                withAnimation(.bouncy) {
                    scrollOffset = CGFloat(newValue.lowerBound) * offset
                }
            }

            .onAppear {
                updateAnimationState()
            }
            .onChange(of: highlightedRange) { oldValue, newValue in
                let isLowerBoundChanged = oldValue.lowerBound != newValue.lowerBound
                let isPauseChanged = oldValue.isEmpty != newValue.isEmpty && canPauseAnimation

                guard isLowerBoundChanged || isPauseChanged else { return }
                updateAnimationState()
            }
            .onChange(of: canPushAnimation) { _, _ in
                tryPushAnimation()
            }
            .observeAnimation(for: scrollOffset) { value in
                scrollPosition.scrollTo(y: value)
            }
        }
    }

    private var hasIndicators: Bool {
        Indicators.self != EmptyView.self
    }

    private var canPauseAnimation: Bool {
        hasIndicators && highlightedRange.isEmpty
    }

    private func updateAnimationState() {
        animationState = .intermediate
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforePush) {
            tryPushAnimation()
        }
    }

    private func tryPushAnimation() {
        guard canPushAnimation, !canPauseAnimation else { return }
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

    private func calculateScrollOffset(for index: Int, in _: CGFloat) -> CGFloat {
        CGFloat(index) * offset
    }
}

#Preview {
    @Previewable @State var canPushAnimation = true
    @Previewable @State var highlightedRange: Range<Int> = 0 ..< 1
    @Previewable @State var alignment: BouncyScrollViewAlignment = .top
    let count = 20

    VStack {
        Picker("Alignment", selection: $alignment) {
            Text("Top")
                .tag(BouncyScrollViewAlignment.top)
            Text("Center")
                .tag(BouncyScrollViewAlignment.center)
            Text("Bottom")
                .tag(BouncyScrollViewAlignment.bottom)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()

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
        .padding()

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
        .padding()

        Button {
            canPushAnimation.toggle()
        } label: {
            if canPushAnimation {
                Text("Disallow Animation Pushing")
            } else {
                Text("Allow Animation Pushing")
            }
        }

        BouncyScrollView(
            canPushAnimation: canPushAnimation,
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
        } indicators: { _, _ in
            EmptyView()
        }
        .border(.foreground)
        .frame(height: 400)
    }
    .frame(width: 400)
}
