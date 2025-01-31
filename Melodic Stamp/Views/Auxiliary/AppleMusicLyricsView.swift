//
//  AppleMusicLyricsView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Defaults
import SwiftUI

struct AppleMusicLyricsLineGeometry {
    var y: CGFloat
    var height: CGFloat
}

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

    @State private var containerSize: CGSize = .zero

    @State private var contentOffset: [Int: CGFloat] = [:]
    @State private var lineOffsets: [Int: AppleMusicLyricsLineGeometry] = [:]

    @State private var isVisible: Bool = false
    @State private var isUserScrolling: Bool = false

    @State private var animationStateDispatch: DispatchWorkItem?

    @Namespace private var coordinateSpace

    // MARK: Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(range, id: \.self) { index in
                        content(at: index)
                            .id(index)
                    }
                }
                .padding(.vertical, containerSize.height / 2)
            }
            .coordinateSpace(name: coordinateSpace)
            .scrollIndicators(isUserScrolling ? .visible : .never)
            .onScrollPhaseChange { phase, _, _ in
                switch phase {
                case .idle:
                    isVisible = false
                    isUserScrolling = false

                case .interacting, .decelerating, .animating, .tracking:
                    isVisible = true
                    isUserScrolling = true
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in // The code below follows a strict order, do not rearrange arbitrarily
                proxy.size
            } action: { newValue in
                containerSize = newValue
                resetScrolling(in: proxy)
            }
            .onChange(of: identifier, initial: true) { _, _ in // Force reset on external change
                resetScrolling(in: proxy)
            }
            .onChange(of: attachments) { _, _ in
                resetScrolling(in: proxy)
            }
            .onChange(of: dynamicTypeSize) { _, _ in
                resetScrolling(in: proxy)
            }
            .onChange(of: highlightedRange) { _, _ in
                scrollToHighlighted(in: proxy)
            }
        }
        .onAppear {
            isVisible = true
            isVisible = false
        }
    }

    @ViewBuilder private func content(at index: Int) -> some View {
        let isHighlighted = highlightedRange.contains(index)
        let isInRange = (highlightedRange.lowerBound - 5...highlightedRange.upperBound + 5).contains(index)
        let isDot = index == highlightedRange.lowerBound

        if isVisible || isInRange {
            content(index, isHighlighted)
                .background {
                    if index == highlightedRange.lowerBound {
                        switch indicator(index, isHighlighted) {
                        case .invisible:
                            EmptyView()
                        case let .visible(content):
                            content
                        }
                    }
                }
                .padding(.vertical, 10)
                .background {
                    GeometryReader { reader in
                        Color.clear.task(id: reader.frame(in: .named(coordinateSpace))) {
                            lineOffsets[index] = AppleMusicLyricsLineGeometry(
                                y: reader.frame(in: .named(coordinateSpace)).minY,
                                height: reader.size.height
                            )
                        }
                    }
                }
                .offset(y: contentOffset[index] ?? 0)

        } else {
            Spacer()
                .frame(height: lineOffsets[index]?.height ?? 20)
        }
    }

    // MARK: Funcitons

    private func resetScrolling(in proxy: ScrollViewProxy) {
        let index = max(0, min(range.upperBound - 1, highlightedRange.lowerBound))
        isVisible = true
        proxy.scrollTo(index, anchor: alignment.unitPoint)
        isVisible = false
    }

    private func scrollToHighlighted(in proxy: ScrollViewProxy) {
        let index = max(0, min(range.upperBound - 1, highlightedRange.lowerBound))
        let adjustItems = max(0, index - 5) ..< index + 5

        guard let offset = lineOffsets[index] else { return }

        withAnimation(nil) {
            proxy.scrollTo(index, anchor: .center)
            for adjustItem in adjustItems {
                contentOffset[adjustItem] = offset.height
            }
        }

        var delay = max(0.0, 0.08 * Double(5 - index))

        for idx in adjustItems {
            delay += 0.08
            withAnimation(.spring(duration: 0.6, bounce: 0.275).delay(delay)) {
                contentOffset[idx] = 0
            }
        }
    }
}

// MARK: - Preview

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
