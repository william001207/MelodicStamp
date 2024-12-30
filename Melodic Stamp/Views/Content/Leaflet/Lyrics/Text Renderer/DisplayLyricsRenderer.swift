//
//  DisplayLyricsRenderer.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

struct DisplayLyricsGroupCache {
    typealias Key = [AnyHashable]
    typealias Value = [AnyHashable: [Text.Layout.RunSlice]]
    typealias Identifier = AnyHashable

    static var shared = Self()

    var groups: [Key: (identifier: Identifier, value: Value)] = [:]

    func contains(key: [some AnimatedString]) -> Bool {
        let hashableKey = key.map(\.self)
        return groups.keys.contains(hashableKey)
    }

    func get<Animated>(
        key: [Animated],
        identifiedBy identifier: Identifier
    ) -> [Animated: [Text.Layout.RunSlice]]? where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        guard let pair = groups[hashableKey] else { return nil }

        guard pair.identifier == identifier else { return nil }
        return pair.value as? [Animated: [Text.Layout.RunSlice]]
    }

    mutating func set<Animated>(
        key: [Animated], value: [Animated: [Text.Layout.RunSlice]],
        identifiedBy identifier: Identifier
    ) where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        groups[hashableKey] = (identifier, value)
    }
}

struct DisplayLyricsRenderer<Animated>: TextRenderer where Animated: AnimatedString {
    var animatableData: TimeInterval {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    var elapsedTime: TimeInterval
    var strings: [Animated]
    var vowels: Set<TimeInterval> = []

    var inactiveOpacity: Double = 0.55
    var blendRadius: Double = 20

    var shadowColor: Color = .white.opacity(0.1)
    var shadowRadius: Double = 5

    var glowColor: Color = .white.opacity(0.65)
    var glowScale: Double = 1.1
    var glowRadius: Double = 8.5
    var glowDelay: TimeInterval = 0.2

    var brightness: Double = 0.5
    var lift: Double = 1.25
    var softness: Double = 0.75

    func timeToVowels(at time: TimeInterval) -> [TimeInterval] {
        vowels
            .map { time - $0 }
            .map(abs)
    }

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
        let identifier = layout.hashValue
        var group: [Animated: [Text.Layout.RunSlice]] = [:]

        if let cached = DisplayLyricsGroupCache.shared.get(key: strings, identifiedBy: identifier) {
            group = cached
        } else {
            group = self.group(layout: layout)
            DisplayLyricsGroupCache.shared.set(key: strings, value: group, identifiedBy: identifier)
        }

        for (index, (lyric, slices)) in group.enumerated() {
            let totalWidth = slices.reduce(0) { $0 + $1.typographicBounds.width }
            var offset: Double = .zero

            for slice in slices {
                let width = slice.typographicBounds.width
                let percentage = offset / totalWidth
                let durationPercentage = width / totalWidth

                let beginTime = lyric.beginTime ?? .zero
                let endTime = lyric.endTime ?? .zero

                draw(
                    slice: slice, index: index,
                    beginTime: beginTime + percentage * (endTime - beginTime),
                    endTime: beginTime + (percentage + durationPercentage) * (endTime - beginTime),
                    in: &context
                )
                offset += width
            }
        }
    }

    func draw(
        slice: Text.Layout.RunSlice, index: Int,
        beginTime: TimeInterval, endTime: TimeInterval,
        in context: inout GraphicsContext
    ) {
        let elapsed = elapsedTime - beginTime
        let duration = endTime - beginTime

        let unclampedProgress = elapsed / duration
        let progress = max(0, min(1, unclampedProgress))
        let softenProgress = max(0, min(1, elapsed / (duration / softness)))

        let bounds = slice.typographicBounds.rect
        let unclampedFilledWidth = bounds.width * unclampedProgress
        let filledWidth = bounds.width * progress
        let liftAmount = lift * bentSigmoid(softenProgress)

        let timeToVowels = timeToVowels(at: self.elapsedTime - Double(index) * glowDelay)

        do {
            var context = context

            // Scale with wave effect
            /*
            if let timeToNearestVowel = timeToVowels.min() {
                for (index, char) in strings.enumerated() {
                    guard let charBeginTime = char.beginTime, let charEndTime = char.endTime else { continue }

                    let charProgress = progressForTime(elapsedTime, charStartTime: charBeginTime, charEndTime: charEndTime)

                    let scale = 1.0 + sin(charProgress * .pi) * 0.2
                    // let dynamicGlowRadius = sin(charProgress * .pi) * 10.0
                    // let opacity = sin(charProgress * .pi) * 0.8 + 0.5

                    context.translateBy(x: bounds.midX, y: bounds.midY)
                    context.scaleBy(x: scale, y: scale)
                    context.translateBy(x: -bounds.midX, y: -bounds.midY)

                    //context.addFilter(.shadow(color: glowColor.opacity(opacity), radius: dynamicGlowRadius))
                }
            }
            */

            // Unfilled
            do {
                var context = context

                context.translateBy(x: 0, y: -liftAmount)
                context.opacity = inactiveOpacity
                context.draw(slice)
            }

            // Filled
            do {
                var context = context
                let mask = Path(.init(
                    x: bounds.minX,
                    y: bounds.minY,
                    width: filledWidth + blendRadius / 2,
                    height: bounds.height
                ))

                // Shadow
                /*
                if let timeToNearestVowel = timeToVowels.min() {
                    let dynamicGlowRadius = sin(progress * .pi) * 10.0
                    context.addFilter(.shadow(color: glowColor, radius: dynamicGlowRadius))
                } else {
                    
                }
                */

                context.addFilter(.shadow(color: shadowColor, radius: shadowRadius))
                // Mask
                context.clipToLayer { context in
                    context.fill(mask, with: .linearGradient(
                        .init(colors: [.white, .clear]),
                        startPoint: .init(x: bounds.minX + unclampedFilledWidth - blendRadius / 2, y: 0),
                        endPoint: .init(x: bounds.minX + unclampedFilledWidth + blendRadius / 2, y: 0)
                    ))
                }

                // Lift
                context.translateBy(x: 0, y: -liftAmount)

                // Brightness
                context.addFilter(.brightness(brightness * progress))

                // Draw
                context.draw(slice)
            }
        }
    }
    /*
    private func progressForTime(_ currentTime: TimeInterval, charStartTime: TimeInterval, charEndTime: TimeInterval) -> Double {
        guard charEndTime > charStartTime else { return 1.0 }
        return min(max((currentTime - charStartTime) / (charEndTime - charStartTime), 0.0), 1.0)
    }
    */

    /// Generates a bell curve value for a given x, mean, standard deviation, and amplitude.
    /// It's worth noting that the integral of this bell curve is not 1, instead, the max value of this bell curve is always 1.
    /// - Parameters:
    ///   - x: The x-value at which to evaluate the bell curve.
    ///   - mean: The mean (center) of the bell curve.
    ///   - standardDeviation: The standard deviation (width) of the bell curve. Higher values result in a wider curve.
    ///   - amplitude: The peak (height) of the bell curve.
    /// - Returns: The y-value of the bell curve at the given x.
    private func bellCurve(
        _ value: Double,
        mean: Double = .zero,
        standardDeviation: Double = 1,
        amplitude: Double = 1
    ) -> CGFloat {
        let exponent = -pow(value - mean, 2) / (2 * pow(standardDeviation, 2))
        return amplitude * exp(exponent)
    }

    /// Sigmoid-like function that bends the input curve around 0.5.
    /// - Parameters:
    ///   - x: The input value, expected to be in the range [0, 1].
    ///   - curvature: A parameter to control the curvature. Higher values create a sharper bend.
    /// - Returns: The transformed output in the range [0, 1].
    private func bentSigmoid(
        _ value: Double,
        curvature: Double = 7.5
    ) -> Double {
        guard curvature != 0 else { return value }
        guard value >= -1, value <= 1 else { return value }

        return value >= 0
            ? 1 / (1 + exp(-curvature * (value - 0.5)))
            : -bentSigmoid(-value)
    }
}
