//
//  ProgressDotsView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

struct ProgressDotsContainerView: View {
    let elapsedTime: TimeInterval
    let beginTime: TimeInterval
    let endTime: TimeInterval

    @State private var isVisible: Bool = true

    var body: some View {
        // Avoids multiple instantializations
        let isVisible = isVisible

        VStack {
            if isVisible {
                ProgressDotsView(elapsedTime: elapsedTime, beginTime: beginTime, endTime: endTime)
                    .frame(width: 150, height: 75, alignment: .leading)
                    .transition(
                        .asymmetric(
                            insertion: .blurTransition(radius: 5)
                                .combined(with: .opacity)
                                .animation(.smooth(duration: 0.75)),
                            removal: .blurTransition(radius: 5)
                                .combined(with: .opacity)
                                .animation(.smooth(duration: 0.75))
                        )
                    )
                    .padding(.vertical, 10)
                    .padding(.horizontal, 2)
            }
        }
        .animation(.default, value: isVisible)
        .onAppear {
            update(time: elapsedTime)
        }
        .onChange(of: elapsedTime) { _, newValue in
            update(time: newValue)
        }
    }

    private func update(time: TimeInterval) {
        isVisible = time >= beginTime && time < endTime - 0.75
    }
}

struct ProgressDotsView: View {
    var elapsedTime: TimeInterval
    var beginTime: TimeInterval
    var endTime: TimeInterval

    private var progress: CGFloat {
        let newEndTime = endTime - 0.75
        let duration = newEndTime - beginTime
        guard duration > 0 else { return 0 }
        return min(max((elapsedTime - beginTime) / duration, 0), 1)
    }

    var body: some View {
        HStack(spacing: progress >= 0.93 ? (progress >= 0.99 ? 3 : 12) : 10) {
            ProgressDotView(progress: progress, activationRange: 0.33...0.66)
            ProgressDotView(progress: progress, activationRange: 0.66...0.90)
            ProgressDotView(progress: progress, activationRange: 0.90...0.95)
        }
        .animation(.smooth(duration: 0.75), value: progress)
    }
}

struct ProgressDotView: View {
    var progress: CGFloat
    var activationRange: ClosedRange<CGFloat>
    @State private var isBreathing = false

    private var activationProgress: Double {
        let normalizedProgress = (progress - activationRange.lowerBound) / (activationRange.upperBound - activationRange.lowerBound)
        return min(max(normalizedProgress, 0), 1)
    }

    private var scale: CGFloat {
        // Handles different states based on progress
        if progress >= 0.99 {
            0.5 + (1 - progress) * 0.5 // Scales down to 0.5 after 0.99
        } else if progress >= 0.93 {
            1 + activationProgress * 0.5 // Scales up between 0.93 and 0.99
        } else {
            isBreathing ? 1.25 : 1.0 // Breathing effect when not active
        }
    }

    private var offset: CGFloat {
        // A slight offset when progress is beyond 0.93
        if progress >= 0.99 {
            CGFloat(activationProgress) * 5
        } else if progress >= 0.91 {
            CGFloat(activationProgress) * -10
        } else {
            0
        }
    }

    private var brightnessAdjustment: CGFloat {
        // Adjusts brightness based on progress
        if progress >= 0.93 {
            activationProgress * 0.75
        } else {
            0
        }
    }

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.25 + 0.75 * activationProgress))
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            // .offset(y: offset)
            .brightness(brightnessAdjustment)
            .onAppear {
                withAnimation(Animation.smooth(duration: 1.5).repeatForever(autoreverses: true)) {
                    isBreathing = true
                }
            }
            .onDisappear {
                withAnimation(Animation.smooth(duration: 1.5).repeatForever(autoreverses: true)) {
                    isBreathing = false
                }
            }
    }
}
