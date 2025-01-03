//
//  MarqueeScrollView.swift
//  Playground
//
//  Created by KrLite on 2024/11/16.
//

import SwiftUI

struct OffsetEffect: GeometryEffect {
    var offset: CGPoint

    init(offset: CGPoint) {
        self.offset = offset
    }

    init(x: CGFloat = .zero, y: CGFloat = .zero) {
        self.init(offset: .init(x: x, y: y))
    }

    var animatableData: CGPoint.AnimatableData {
        get { CGPoint.AnimatableData(offset.x, offset.y) }
        set { offset = .init(x: newValue.first, y: newValue.second) }
    }

    public func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: offset.x, y: offset.y))
    }
}

struct MarqueeScrollView<Content>: View where Content: View {
    enum AnimationStage {
        case idle
        case preparing
        case animating
    }

    var duration: TimeInterval = 5
    var delay: TimeInterval = 1
    var overflow: CGFloat = 12
    var animate: Bool = true
    @ViewBuilder var content: () -> Content

    @State private var offset: CGFloat = .zero
    @State private var animationOffset: CGFloat = .zero

    @State private var contentSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero
    @State private var scrollPosition: ScrollPosition = .init()

    @State private var idleTimer: Timer?
    @State private var stage: AnimationStage = .idle

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            content()
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { size in
                    if animate {
                        withAnimation {
                            contentSize = size
                        }
                    } else {
                        contentSize = size
                    }

                    DispatchQueue.main.async {
                        pauseAnimation()
                        resetScrollPosition()
                        unidle()
                    }
                }
                .modifier(OffsetEffect(x: -animationOffset))
        }
        .scrollPosition($scrollPosition, anchor: .leading)
        .scrollDisabled(!canMarquee)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            if animate {
                withAnimation {
                    containerSize = size
                }
            } else {
                containerSize = size
            }

            DispatchQueue.main.async {
                pauseAnimation()
                resetScrollPosition()
                unidle()
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.x
        } action: { _, newValue in
            offset = newValue

            if scrollPosition.isPositionedByUser {
                idle()
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase, _ in
            if newPhase.isScrolling {
                idle()
            } else if oldPhase.isScrolling {
                unidle()
            }
        }

        .padding(.horizontal, -overflow)
        .contentMargins(.horizontal, overflow)
        .mask {
            if overflow > 0 {
                HStack(spacing: 0) {
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                        .frame(width: overflow)

                    Color.white
                        .frame(width: max(0, visibleLength))

                    LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: overflow)
                }
            } else {
                Color.white
            }
        }

        .observeAnimation(for: animationOffset) { newValue in
            offset = newValue
        }
    }

    private var visibleLength: CGFloat {
        containerSize.width - 2 * overflow
    }

    private var scrollableLength: CGFloat {
        contentSize.width
    }

    private var canMarquee: Bool {
        // do not overflow
        contentSize.width > visibleLength
    }

    private func duration(percentage: CGFloat) -> TimeInterval {
        max(0, duration * percentage)
    }

    private func idle() {
        idleTimer?.invalidate()
        idleTimer = nil

        if stage != .idle {
            pauseAnimation()
            scrollPosition.scrollTo(x: offset)
        }
    }

    private func unidle() {
        idleTimer?.invalidate()

        guard canMarquee else { return }

        idleTimer = .scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            resumeAnimation()
        }
    }

    private func resetScrollPosition() {
        scrollPosition.scrollTo(x: 0)
    }

    private func resumeAnimation() {
        guard canMarquee else { return }

        resetScrollPosition()
        switch stage {
        case .idle:
            withAnimation(.instant) {
                stage = .preparing
                animationOffset = offset + overflow
            } completion: {
                resumeAnimation()
            }
        case .preparing:
            withAnimation(.linear(duration: duration(percentage: offset / (scrollableLength - visibleLength)))) {
                stage = .animating
                animationOffset = 0
            } completion: {
                resumeAnimation()
            }
        case .animating:
            withAnimation(.linear(duration: duration).delay(delay).repeatForever(autoreverses: true)) {
                animationOffset = scrollableLength - visibleLength
            }
        }
    }

    private func pauseAnimation() {
        withAnimation(.instant) {
            stage = .idle
            animationOffset = 0
        }
    }
}

struct ShrinkableMarqueeScrollView<Content>: View where Content: View {
    var duration: TimeInterval = 5
    var delay: TimeInterval = 1
    var overflow: CGFloat = 12
    @ViewBuilder var content: () -> Content

    @State private var contentSize: CGSize = .zero

    var body: some View {
        MarqueeScrollView(
            duration: duration,
            delay: delay,
            overflow: overflow
        ) {
            content()
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { size in
                    withAnimation {
                        contentSize = size
                    }
                }
        }
        .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
    }
}

#Preview {
    VStack {
        MarqueeScrollView {
            Text("Lorem ipsum.")
                .padding(4)
        }
        .background(.quinary)

        MarqueeScrollView {
            Text("Lorem consequat anim ea. Ad est id mollit proident elit esse quis. Sint elit officia irure voluptate dolor labore voluptate excepteur sit sunt nostrud.")
                .padding(4)
        }
        .background(.quinary)
    }
    .frame(width: 250)
    .padding()
}

#Preview {
    VStack {
        ShrinkableMarqueeScrollView {
            Text("Lorem ipsum.")
                .padding(4)
        }
        .background(.quinary)

        ShrinkableMarqueeScrollView {
            Text("Lorem consequat anim ea. Ad est id mollit proident elit esse quis. Sint elit officia irure voluptate dolor labore voluptate excepteur sit sunt nostrud.")
                .padding(4)
        }
        .background(.quinary)
    }
    .frame(width: 250)
    .padding()
}
