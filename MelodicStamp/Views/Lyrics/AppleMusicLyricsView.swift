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

    var unitPoint: UnitPoint {
        switch self {
        case .top: .top
        case .center: .center
        }
    }
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

// MARK: Apple Music Lyrics View

extension AppleMusicLyricsView: TypeNameReflectable {}

struct AppleMusicLyricsView<Content>: View where Content: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Default(.lyricsAttachments) private var attachments

    // MARK: Fields

    var padding: CGFloat = 50
    var delay: TimeInterval = 0.1
    var bounceDelay: TimeInterval = 0.175

    var range: Range<Int>
    var highlightedRange: Range<Int>
    var alignment: AppleMusicLyricsViewAlignment = .top
    var identifier: AnyHashable?

    @ViewBuilder var content: (_ index: Int, _ isHighlighted: Bool) -> Content
    var indicator: (_ index: Int, _ isHighlighted: Bool) -> AppleMusicLyricsViewIndicator

    @State private var previousHighlightedRange: Range<Int>?

    @State private var scrollPosition = ScrollPosition(idType: Int.self)
    @State private var containerSize: CGSize = .zero

    @State private var contentOffset: [Int: CGFloat] = [:]
    @State private var lineOffsets: [Int: CGFloat] = [:]

    @State private var isUserScrolling: Bool = false

    @State private var animationStateDispatch: DispatchWorkItem?

    @Namespace private var coordinateSpace

    // MARK: Body

    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: containerSize.height / 2)

            LazyVStack(spacing: .zero) {
                ForEach(range, id: \.self) { index in
                    content(at: index)
                        .id(index)
                }
            }

            Spacer()
                .frame(height: containerSize.height / 2)
        }
        .scrollPosition($scrollPosition, anchor: .center)
        .scrollIndicators(isUserScrolling ? .visible : .hidden)
        .onScrollPhaseChange { _, phase, _ in
            switch phase {
            case .idle:
                isUserScrolling = true

                animationStateDispatch?.cancel()

                animationStateDispatch = DispatchWorkItem {
                    isUserScrolling = false
                }

                if let dispatchItem = animationStateDispatch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: dispatchItem)
                }

            case .interacting, .decelerating, .animating, .tracking:
                isUserScrolling = false

                animationStateDispatch?.cancel()
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in // The code below follows a strict order, do not rearrange arbitrarily
            proxy.size
        } action: { newValue in
            containerSize = newValue
            resetScrolling()
        }
        .onChange(of: identifier, initial: true) { _, _ in // Force reset on external change
            apperScolling()
        }
        .onChange(of: attachments) { _, _ in
            resetScrolling()
        }
        .onChange(of: dynamicTypeSize) { _, _ in
            resetScrolling()
        }
        .onChange(of: highlightedRange) { oldValue, newValue in
            let isLowerBoundJumped = abs(newValue.lowerBound - oldValue.lowerBound) > 1
            let isUpperBoundJumped = abs(newValue.upperBound - oldValue.upperBound) > 1
            let isJumped = newValue.lowerBound < oldValue.lowerBound || (isLowerBoundJumped && isUpperBoundJumped)

            if isJumped {
                resetScrolling()
            } else {
                scrollToHighlighted()
            }
        }
        .onAppear {
            apperScolling()
        }
    }

    @ViewBuilder private func content(at index: Int) -> some View {
        let isHighlighted = highlightedRange.contains(index)

        content(index, isHighlighted)
            .padding(.vertical, 10)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                lineOffsets[index] = newValue.height
            }
            .offset(y: contentOffset[index] ?? 0)
            .background {
                if index == highlightedRange.lowerBound {
                    switch indicator(index, isHighlighted) {
                    case .invisible:
                        EmptyView()
                    case let .visible(content):
                        content
                            .padding(.vertical, 10)
                    }
                }
            }
    }

    // MARK: Funcitons

    private func apperScolling() {
        let index = max(0, min(range.upperBound - 1, highlightedRange.lowerBound))
        guard let offset = lineOffsets[index] else { return }

        withAnimation(nil) {
            scrollPosition.scrollTo(id: index, anchor: .center)
            for adjustItem in range {
                contentOffset[adjustItem] = offset
            }
        }
    }

    private func resetScrolling() {
        scrollPosition.scrollTo(id: highlightedRange.lowerBound, anchor: .center)

        for idx in range {
            contentOffset[idx] = 0
        }
    }

    private func scrollToHighlighted() {
        let index = max(0, min(range.upperBound - 1, highlightedRange.lowerBound))

        guard let offset = lineOffsets[index] else { return }

        let previousOffset = (index > 0) ? (lineOffsets[index - 1] ?? 0) : 0
        let nextOffset = (index < lineOffsets.count - 1) ? (lineOffsets[index] ?? 0) : 0

        let diffBefore = abs(CGFloat(offset) - CGFloat(previousOffset))
        let diffAfter = abs(CGFloat(nextOffset) - CGFloat(offset))

        let compensate: CGFloat = if diffBefore > diffAfter {
            (CGFloat(previousOffset) - CGFloat(offset)) / 2
        } else {
            (CGFloat(nextOffset) - CGFloat(offset)) / 2
        }

        withAnimation(nil) {
            if let range = previousHighlightedRange, highlightedRange.lowerBound != range.lowerBound {
                if highlightedRange.lowerBound != self.range.upperBound {
                    scrollPosition.scrollTo(id: index, anchor: .center)

                    var testOffset: CGFloat = 0

                    var totalOffset: CGFloat = (range.lowerBound ..< range.upperBound).reduce(0) { result, idx in
                        testOffset = result
                        return result + (lineOffsets[idx] ?? 0)
                    }

                    for idx in highlightedRange.lowerBound ..< highlightedRange.upperBound {
                        if highlightedRange.lowerBound != highlightedRange.upperBound {
                            if highlightedRange.upperBound != self.range.upperBound {
                                totalOffset = (lineOffsets[idx] ?? 0) + compensate + testOffset
                            } else {
                                totalOffset = totalOffset
                            }
                        } else {
                            totalOffset = totalOffset
                        }
                    }

                    for idx in (index - 10) ..< index where idx >= 0 {
                        contentOffset[idx] = totalOffset
                    }

                    for idx in index ..< index + 10 {
                        contentOffset[idx] = totalOffset
                    }
                }
            }
        }

        if highlightedRange.lowerBound != range.upperBound {
            var delay = 0.08

            for idx in (index - 10) ..< index where idx >= 0 {
                withAnimation(.spring(duration: 0.6, bounce: 0.275)) {
                    contentOffset[idx] = 0
                }
            }

            if highlightedRange.upperBound != highlightedRange.lowerBound {
                for idx in index ..< index + 10 {
                    delay += 0.08
                    withAnimation(.spring(duration: 0.6, bounce: 0.275).delay(delay)) {
                        contentOffset[idx] = 0
                    }
                }
            } else if let range = previousHighlightedRange, highlightedRange.lowerBound != range.lowerBound {
                for idx in index ..< index + 10 {
                    delay += 0.08
                    withAnimation(.spring(duration: 0.6, bounce: 0.275).delay(delay)) {
                        contentOffset[idx] = previousOffset
                    }
                }
            }
        }

        previousHighlightedRange = highlightedRange
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var highlightedRange: Range<Int> = 0 ..< 0
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

            Button("Waiting") {
                highlightedRange = highlightedRange.lowerBound + 1 ..< highlightedRange.upperBound
            }

            Button("Next") {
                highlightedRange = highlightedRange.lowerBound + 1 ..< highlightedRange.upperBound + 1
            }

            Button("Cancel waiting") {
                highlightedRange = highlightedRange.lowerBound ..< highlightedRange.upperBound + 1
            }

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
            range: 0 ..< count,
            highlightedRange: highlightedRange,
            alignment: alignment
        ) { index, isHighlighted in
            Text("\(index)")
                .font(.title)
                .shadow(radius: 4)
                .frame(height: index % 2 == 0 ? 70 : 50)
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
                        .frame(width: 10)
                    Circle()
                        .frame(width: 10)
                    Circle()
                        .frame(width: 10)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .border(.foreground)
        .frame(height: 400)
    }
    .frame(width: 400)
}
