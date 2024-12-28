//
//  DisplayLyricsRenderer.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

struct DisplayLyricsRenderer<Animated>: TextRenderer where Animated: AnimatedString {
    var animatableData: TimeInterval {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    var elapsedTime: TimeInterval
    var strings: [Animated]

    var inactiveOpacity: CGFloat = 0.55
    var blendRadius: CGFloat = 20
    var shadowColor: Color = .white.opacity(0.1)
    var shadowRadius: CGFloat = 5

    var brightness: CGFloat = 0.5
    var lift: CGFloat = 2.5
    var softness: CGFloat = 0.75

    func group(layout: Text.Layout) -> [Animated: [Text.Layout.RunSlice]] {
        let slices = Array(layout.flattenedRunSlices)
        var result: [Animated: [Text.Layout.RunSlice]] = [:]
        var index = 0

        for string in strings {
            let count = string.content.count
            let endIndex = index + count
            guard endIndex <= slices.endIndex else { break }

            result.updateValue(
                Array(slices[index ..< endIndex]),
                forKey: string
            )
            index = endIndex
        }
        return result
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for (lyric, slices) in group(layout: layout) {
            let totalWidth = slices.reduce(0) { $0 + $1.typographicBounds.width }
            var offset: CGFloat = 0

            for slice in slices {
                let width = slice.typographicBounds.width
                let percentage = offset / totalWidth
                let durationPercentage = width / totalWidth
                draw(
                    slice: slice,
                    beginTime: (lyric.beginTime ?? 0) + percentage * ((lyric.endTime ?? 0) - (lyric.beginTime ?? 0)),
                    endTime: (lyric.beginTime ?? 0) + (percentage + durationPercentage) * ((lyric.endTime ?? 0) - (lyric.beginTime ?? 0)),
                    in: &context
                )
                offset += width
            }
        }
    }

    func draw(
        slice: Text.Layout.RunSlice,
        beginTime: TimeInterval, endTime: TimeInterval,
        in context: inout GraphicsContext
    ) {
        let elapsedTime = elapsedTime - beginTime
        let duration = endTime - beginTime

        let unclampedProgress: Double = elapsedTime / duration
        let progress: Double = max(0, min(1, unclampedProgress))
        let softenProgress: Double = max(0, min(1, elapsedTime / (duration / softness)))

        let bounds = slice.typographicBounds.rect
        let unclampedFilledWidth = bounds.width * CGFloat(unclampedProgress)
        let filledWidth = bounds.width * CGFloat(progress)
        let lift = lift * damping(CGFloat(softenProgress))

        // Unfilled
        do {
            var context = context

            context.translateBy(x: 0, y: -lift)
            context.opacity = inactiveOpacity
            context.draw(slice)
        }

        // Filled
        do {
            let mask = Path(.init(
                x: bounds.minX,
                y: bounds.minY,
                width: filledWidth + blendRadius / 2,
                height: bounds.height
            ))

            var context = context
            context.addFilter(.shadow(color: shadowColor, radius: shadowRadius))
            context.clipToLayer { context in
                context.fill(mask, with: .linearGradient(
                    .init(colors: [.white, .clear]),
                    startPoint: .init(x: bounds.minX + unclampedFilledWidth - blendRadius / 2, y: 0),
                    endPoint: .init(x: bounds.minX + unclampedFilledWidth + blendRadius / 2, y: 0)
                ))
            }

            context.translateBy(x: 0, y: -lift)
            context.addFilter(.brightness(Double(brightness) * progress))

            context.draw(slice)
        }
    }

    private func damping(_ t: CGFloat, stiffness: CGFloat = 1, ratio: CGFloat = 0.5) -> CGFloat {
        guard t >= 0, t <= 1 else { return t }

        let omega0 = sqrt(stiffness) // Natural frequency
        let damping = 2 * ratio * omega0 // Damping coefficient
        let expDecay = exp(-damping * t) // Exponential decay
        let oscillation = cos(omega0 * sqrt(1 - pow(ratio, 2)) * t)

        return 1 - expDecay * oscillation
    }
}
