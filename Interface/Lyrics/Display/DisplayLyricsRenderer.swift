//
//  DisplayLyricsRenderer.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import Collections
import SmartCache
import SwiftUI

struct DisplayLyricsGroupCache {
    typealias Key = [AnyHashable]
    typealias Value = OrderedDictionary<AnyHashable, [Text.Layout.RunSlice]>
    typealias Identifier = AnyHashable

    static var shared = Self()

    let cache: MemoryCache<Key, (identifier: Identifier, value: Value)> = .init(maximumCachedValues: 16)

    func contains(key: [some AnimatedString]) -> Bool {
        let hashableKey = key.map(\.self)
        return cache.value(forKey: hashableKey) != nil
    }

    func get<Animated>(
        key: [Animated],
        identifiedBy identifier: Identifier
    ) -> OrderedDictionary<Animated, [Text.Layout.RunSlice]>? where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        guard let pair = cache.value(forKey: hashableKey) else { return nil }

        guard pair.identifier == identifier else { return nil }
        return pair.value as? OrderedDictionary<Animated, [Text.Layout.RunSlice]>
    }

    mutating func set<Animated>(
        key: [Animated], value: OrderedDictionary<Animated, [Text.Layout.RunSlice]>,
        identifiedBy identifier: Identifier
    ) where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        guard let value = value as? Value else { return }
        cache.insert((identifier, value), forKey: hashableKey)
    }
}

struct DisplayLyricsRenderer<Animated>: TextRenderer where Animated: AnimatedString {
    var animatableData: TimeInterval {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    var elapsedTime: TimeInterval
    var strings: [Animated]
    var vowelTimes: Set<TTMLVowelTime> = []

    var inactiveOpacity: Double = 0.55
    var blendRadius: Double = 20

    var shadowColor: Color = .white.opacity(0.1)
    var shadowRadius: Double = 5

    var glowColor: Color = .white.opacity(0.85)
    var glowRadius: Double = 5

    var wave: Double = 1.075
    var waveDelay: TimeInterval = 0.102
    var waveActivationDelay: TimeInterval = 0.07

    var brightness: Double = 0.5
    var lift: Double = 1.25
    var softness: Double = 0.75

    func timeToVowels(at time: TimeInterval) -> [(mark: TimeInterval, time: TTMLVowelTime)] {
        vowelTimes
            .map { (time - $0.beginTime, $0) }
            .map { (abs($0), $1) }
    }

    func group(layout: Text.Layout) -> OrderedDictionary<Animated, [Text.Layout.RunSlice]> {
        let slices = Array(layout.flattenedRunSlices)
        var result: OrderedDictionary<Animated, [Text.Layout.RunSlice]> = [:]
        var index = 0

        for string in strings {
            let count = string.content.count
            let endIndex = index + count
            guard endIndex <= slices.endIndex else { break }

            result.updateValue(Array(slices[index ..< endIndex]), forKey: string)
            index = endIndex
        }
        return result
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let identifier = layout.hashValue
        var group: OrderedDictionary<Animated, [Text.Layout.RunSlice]> = [:]

        if let cached = DisplayLyricsGroupCache.shared.get(key: strings, identifiedBy: identifier) {
            group = cached
        } else {
            group = self.group(layout: layout)
            DisplayLyricsGroupCache.shared.set(key: strings, value: group, identifiedBy: identifier)
        }

        var accumulatedIndex: Int = .zero

        for (lyric, slices) in group {
            let totalWidth = slices.reduce(0) { $0 + $1.typographicBounds.width }
            var offset: Double = .zero

            for slice in slices {
                let width = slice.typographicBounds.width
                let percentage = offset / totalWidth
                let durationPercentage = width / totalWidth

                let beginTime = lyric.beginTime ?? .zero
                let endTime = lyric.endTime ?? .zero
                let duration = endTime - beginTime

                draw(
                    slice: slice, index: accumulatedIndex,
                    beginTime: beginTime + duration * percentage,
                    endTime: beginTime + duration * (percentage + durationPercentage),
                    in: &context
                )
                offset += width
                accumulatedIndex += 1
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
        // let softenProgress = max(0, min(1, elapsed / (duration / softness)))

        let bounds = slice.typographicBounds.rect
        let unclampedFilledWidth = bounds.width * unclampedProgress
        let filledWidth = bounds.width * progress
        // let liftAmount = lift * bentSigmoid(softenProgress)

        let waveDelay = waveDelay * Double(index) - waveActivationDelay
        let timeToVowels = timeToVowels(at: elapsedTime - waveDelay)

        do {
            var context = context

            // Premultiplied wave & glow effect for long vowels

            wave: do {
                if let timeToNearestVowel = timeToVowels.sorted(by: { $0.mark < $1.mark }).first {
                    let isInRange = timeToNearestVowel.time.contains(time: beginTime)
                    guard isInRange else { break wave }

                    let waveProgress = bellCurve(timeToNearestVowel.mark, standardDeviation: 0.325) + 0.10
                    guard waveProgress > 1e-6 else { break wave }

                    // Scale
                    let waveAmount = waveProgress * (wave - 1) + 1
                    context.translateBy(x: bounds.width / 2, y: bounds.height / 2)
                    context.scaleBy(x: waveAmount, y: waveAmount)
                    context.translateBy(x: -bounds.width / 2, y: -bounds.height / 2)

                    // Glow
                    context.addFilter(.shadow(
                        color: glowColor.opacity(waveProgress),
                        radius: glowRadius * waveProgress
                    ))
                }
            }

            // Unfilled text
            do {
                var context = context

                /*
                 context.translateBy(x: 0, y: -liftAmount)
                  */
                context.opacity = inactiveOpacity
                context.draw(slice)
            }

            // Filled text
            do {
                var context = context
                let mask = Path(.init(
                    x: bounds.minX,
                    y: bounds.minY,
                    width: filledWidth + blendRadius / 2,
                    height: bounds.height
                ))

                // Shadow
                // context.addFilter(.shadow(color: shadowColor, radius: shadowRadius))

                // Mask
                context.clipToLayer { context in
                    context.fill(mask, with: .linearGradient(
                        .init(colors: [.white, .clear]),
                        startPoint: .init(x: bounds.minX + unclampedFilledWidth - blendRadius / 2, y: 0),
                        endPoint: .init(x: bounds.minX + unclampedFilledWidth + blendRadius / 2, y: 0)
                    ))
                }

                // Lift
                // context.translateBy(x: 0, y: -liftAmount)

                // Brightness
                context.addFilter(.brightness(brightness * progress))

                // Draw
                context.draw(slice)
            }
        }
    }
}
