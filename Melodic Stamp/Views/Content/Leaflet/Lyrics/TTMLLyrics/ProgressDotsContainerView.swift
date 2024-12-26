//
//  ProgressDotsContainerView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

struct ProgressDotsContainerView: View {
    let currentTime: TimeInterval
    let startTime: TimeInterval
    let endTime: TimeInterval
    @State private var showProgressDots: Bool = true
    
    var body: some View {
        VStack {
            if showProgressDots {
                ProgressDotsView(currentTime: currentTime, startTime: startTime, endTime: endTime)
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
                    .padding(.horizontal, 10)
            }
        }
        .onAppear {
            checkTimeAndUpdate()
        }
        .onChange(of: currentTime) { _, _ in
            checkTimeAndUpdate()
        }
    }
    
    private func checkTimeAndUpdate() {
        withAnimation {
            showProgressDots = currentTime >= startTime && currentTime < endTime
        }
    }
}

struct ProgressDotsView: View {
    var currentTime: TimeInterval
    var startTime: TimeInterval
    var endTime: TimeInterval
    
    private var progress: Double {
        let totalTime = endTime - startTime
        guard totalTime > 0 else { return 0 }
        return min(max((currentTime - startTime) / totalTime, 0), 1)
    }
    
    var body: some View {
        HStack(spacing: progress >= 0.93 ? (progress >= 0.99 ? 3 : 12) : 10) {
            DotView(progress: progress, activationRange: 0.33...0.66)
            DotView(progress: progress, activationRange: 0.66...0.90)
            DotView(progress: progress, activationRange: 0.90...0.96)
        }
        .animation(.smooth(duration: 0.75), value: progress)
    }
}

struct DotView: View {
    var progress: Double
    var activationRange: ClosedRange<Double>
    @State private var isBreathing = false
    
    private var activationProgress: Double {
        let normalizedProgress = (progress - activationRange.lowerBound) / (activationRange.upperBound - activationRange.lowerBound)
        return min(max(normalizedProgress, 0), 1)
    }
    
    private var scale: CGFloat {
        // Handle different states based on progress
        if progress >= 0.99 {
            return 0.5 + CGFloat((1 - progress) * 0.5) // Scale down to 0.5 after 0.99
        } else if progress >= 0.93 {
            return 1.0 + CGFloat(activationProgress) * 0.5 // Scale up between 0.93 and 0.99
        } else {
            return isBreathing ? 1.25 : 1.0 // Breathing effect when not active
        }
    }
    
    /*
    private var offset: CGFloat {
        // Add a slight offset when progress is beyond 0.93
        if progress >= 0.99 {
            return CGFloat(activationProgress) * 5 // Offset between 0 to -10 based on activationProgress
        } else if progress >= 0.91 {
            return CGFloat(activationProgress) * -10
        } else {
            return 0
        }
    }
    */
    
    private var brightnessAdjustment: Double {
        // Adjust brightness based on progress
        if progress >= 0.93 {
            return Double(activationProgress) * 0.75 // Brightness adjustment
        } else {
            return 0
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
