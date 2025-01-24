//
//  AppleMusicLyricsView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Defaults
import SwiftUI

enum AppleMusicLyricsViewAnimationState {
    case intermediate
    case pushed
}

enum AppleMusicLyricsViewAlignment {
    case top
    case center
}

enum AppleMusicLyricsViewInteractionState {
    case following
    case isolated
    case intermediate
    case countingDown

    var isDelegated: Bool {
        switch self {
        case .following: true
        default: false
        }
    }

    var isIsolated: Bool {
        switch self {
        case .isolated: true
        default: false
        }
    }
}

enum AppleMusicLyricsViewIndicator {
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

struct AppleMusicLyricsView<Content>: View where Content: View {
    struct Origin {
        var offset: CGFloat
        var index: Int
        var isInitialized: Bool = true

        static var zero: Self { .init(offset: .zero, index: .zero) }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Default(.lyricsAttachments) private var attachments

    var interactionState: AppleMusicLyricsViewInteractionState = .following

    var padding: CGFloat = 50
    var delay: TimeInterval = 0.1
    var bounceDelay: TimeInterval = 0.175

    var range: Range<Int>
    var highlightedRange: Range<Int>
    var alignment: AppleMusicLyricsViewAlignment = .top
    var identifier: AnyHashable?

    @ViewBuilder var content: (_ index: Int, _ isHighlighted: Bool) -> Content
    var indicator: (_ index: Int, _ isHighlighted: Bool) -> AppleMusicLyricsViewIndicator

    var onScrolling: ((ScrollPosition, CGPoint) -> ())?

    @State private var containerSize: CGSize = .zero
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var scrollOffset: CGFloat = .zero

    @State private var animationState: AppleMusicLyricsViewAnimationState = .intermediate
    @State private var contentOffsets: [Int: CGFloat] = [:]
    @State private var origin: Origin = .zero

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer()
                    .frame(height: containerSize.height / 2)

                LazyVStack(spacing: 0) {
                    ForEach(range, id: \.self) { index in
                        content(at: index)
                    }
                }

                Spacer()
                    .frame(height: containerSize.height / 2)
            }
            .contentMargins(.vertical, padding, for: .scrollContent)
            .contentMargins(.horizontal, 12, for: .scrollContent)
            .scrollIndicators(interactionState.isDelegated ? .never : .visible)
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGPoint.self) { proxy in
                proxy.contentOffset
            } action: { _, newValue in
                if !origin.isInitialized {
                    scrollOffset = newValue.y
                    origin.offset = newValue.y
                    origin.isInitialized = true
                    print(newValue.y)
                }

                if scrollPosition.isPositionedByUser {
                    scrollOffset = newValue.y
                    onScrolling?(scrollPosition, newValue)
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                containerSize = newValue
            }
            // The code below follows a strict order, do not rearrange arbitrarily
            .onChange(of: identifier, initial: true) { _, _ in
                // Force reset on external change
                updateAnimationState()
                resetScrolling(in: proxy)
            }
            .onChange(of: highlightedRange) { _, _ in
                withAnimation(.spring(duration: 0.65, bounce: 0.275)) {
                    scrollToHighlighted()
                }
            }
            .onChange(of: highlightedRange) { oldValue, newValue in
                let isLowerBoundChanged = oldValue.lowerBound != newValue.lowerBound
                let isUpperBoundChanged = oldValue.upperBound != newValue.upperBound

                if isLowerBoundChanged {
                    updateAnimationState()
                } else if isUpperBoundChanged {
                    pushAnimation()
                }
            }
            .onChange(of: contentOffsets) { _, _ in
                withAnimation(.spring(duration: 0.65, bounce: 0.275)) {
                    scrollToHighlighted()
                }
            }
            .onChange(of: interactionState) { _, _ in
                // Scrolls to highlighted when externally allowed
                withAnimation(.smooth) {
                    scrollToHighlighted()
                }
            }
            .observeAnimation(for: scrollOffset) { value in
                scrollPosition.scrollTo(y: value)
            }
        }
    }

    private var isIndicatorVisible: Bool {
        indicator(highlightedRange.lowerBound, true).isVisible
    }

    private var reachedEnd: Bool {
        highlightedRange.lowerBound >= range.upperBound
    }

    private var canPauseAnimation: Bool {
        highlightedRange.isEmpty && isIndicatorVisible
    }

    private var alignmentCompensation: CGFloat {
        switch alignment {
        case .top:
            (containerSize.height - padding) / 2
        case .center:
            if let offset = contentOffsets[highlightedRange.lowerBound] {
                (offset + padding) / 2
            } else {
                padding / 2
            }
        }
    }

    private var animationCompensation: CGFloat {
        contentOffsets[max(0, highlightedRange.upperBound - 1)] ?? .zero
    }

    @ViewBuilder private func content(at index: Int) -> some View {
        let isHighlighted = highlightedRange.contains(index)
        let delay = delay(at: index)
        let proportion = proportion(at: index)

        let compensate = interactionState.isDelegated || isIndicatorVisible ? animationCompensation : .zero

        content(index, isHighlighted)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                contentOffsets.updateValue(newValue.height, forKey: index)
            }
            .id(index)
            .offset(y: proportion * compensate)
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
            .animation(.spring(duration: 0.65, bounce: 0.275).delay(delay), value: animationState)
            .animation(.spring(duration: 0.55, bounce: 0.15), value: highlightedRange)
            .animation(.spring(duration: 0.75, bounce: 0.30), value: animationCompensation)
            .animation(.smooth, value: interactionState.isDelegated)
    }

    private func resetScrolling(in proxy: ScrollViewProxy) {
        guard interactionState.isDelegated else { return }
        origin.isInitialized = false
        let index = max(0, min(range.upperBound - 1, highlightedRange.lowerBound))
        proxy.scrollTo(index, anchor: .center)
    }

    private func scrollToHighlighted() {
        guard interactionState.isDelegated else { return }
        scrollOffset = max(0, origin.offset + fold(until: highlightedRange.lowerBound) + alignmentCompensation)
    }

    private func fold(until index: Int) -> CGFloat {
        contentOffsets
            .filter { $0.key < index && $0.key >= origin.index }
            .map(\.value)
            .reduce(0, +)
    }

    private func updateAnimationState() {
        guard !reachedEnd else { return }
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
        guard index >= highlightedRange.lowerBound else { return .zero }
        return switch animationState {
        case .intermediate: 1
        case .pushed: 0
        }
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
    @Previewable @State var alignment: AppleMusicLyricsViewAlignment = .top
    let count = 20

    VStack {
        VStack {
            Picker("Alignment", selection: $alignment) {
                Text("Top")
                    .tag(AppleMusicLyricsViewAlignment.top)
                Text("Center")
                    .tag(AppleMusicLyricsViewAlignment.center)
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

        AppleMusicLyricsView(
            padding: 0,
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
