//
//  DisplayLyricsRenderer.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

struct DisplayLyricsGroupCache {
    static var shared = Self()

    var groups: [[AnyHashable]: [AnyHashable: [Text.Layout.RunSlice]]] = [:]

    func contains(key: [some AnimatedString]) -> Bool {
        let hashableKey = key.map(\.self)
        return groups[hashableKey]?.keys.contains(hashableKey) ?? false
    }

    func get<Animated>(key: [Animated]) -> [Animated: [Text.Layout.RunSlice]]? where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        return groups[hashableKey] as? [Animated: [Text.Layout.RunSlice]]
    }

    mutating func set<Animated>(key: [Animated], value: [Animated: [Text.Layout.RunSlice]]) where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        groups[hashableKey] = value
    }
}
/*
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
        var group: [Animated: [Text.Layout.RunSlice]] = [:]

        // Cache grouping result if possible
        // Since the grouping should always be identical to an array of animated strings
        if let cached = DisplayLyricsGroupCache.shared.get(key: strings) {
            group = cached
        } else {
            group = self.group(layout: layout)
            DisplayLyricsGroupCache.shared.set(key: strings, value: group)
        }

        for (lyric, slices) in group {
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
*/

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
    
    private var specialGroups: [Range<Int>] = []
    
    init(elapsedTime: TimeInterval, strings: [Animated]) {
        self.elapsedTime = elapsedTime
        self.strings = strings
        self.specialGroups = Self.findSpecialGroups(in: strings)
    }
    
    static func findSpecialGroups(in strings: [Animated]) -> [Range<Int>] {
        var groups: [Range<Int>] = []
        var currentGroupStart: Int?
        var currentGroupDuration: TimeInterval = 0
        var currentGroupChars: Int = 0
        
        for (index, string) in strings.enumerated() {
            let isLatin = string.content.range(of: "^[A-Za-z-]+$", options: .regularExpression) != nil
            let hasSpace = string.content.contains(" ")
            
            if isLatin && !hasSpace {
                if currentGroupStart == nil {
                    currentGroupStart = index
                }
                currentGroupDuration += (string.endTime ?? 0) - (string.beginTime ?? 0)
                currentGroupChars += string.content.count
            } else {
                if let start = currentGroupStart {
                    if currentGroupDuration > 0.9 && currentGroupChars >= 3 {
                        groups.append(start..<index)
                    }
                    currentGroupStart = nil
                    currentGroupDuration = 0
                    currentGroupChars = 0
                }
            }
        }
        
        if let start = currentGroupStart, currentGroupDuration > 0.9, currentGroupChars >= 3 {
            groups.append(start..<strings.count)
        }
        return groups
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
        var group: [Animated: [Text.Layout.RunSlice]] = [:]
        
        if let cached = DisplayLyricsGroupCache.shared.get(key: strings) {
            group = cached
        } else {
            group = self.group(layout: layout)
            DisplayLyricsGroupCache.shared.set(key: strings, value: group)
        }
        
        for (lyric, slices) in group {
            guard let index = strings.firstIndex(where: { $0.id == lyric.id }) else { continue }
            
            let isSpecial = specialGroups.contains { $0.contains(index) }
            
            let totalWidth = slices.reduce(0) { $0 + $1.typographicBounds.width }
            var offset: CGFloat = 0
            
            for slice in slices {
                let width = slice.typographicBounds.width
                let percentage = offset / totalWidth
                let durationPercentage = width / totalWidth
                
                if isSpecial {
                    drawSpecial(
                        slice: slice,
                        beginTime: (lyric.beginTime ?? 0) + percentage * ((lyric.endTime ?? 0) - (lyric.beginTime ?? 0)),
                        endTime: (lyric.beginTime ?? 0) + (percentage + durationPercentage) * ((lyric.endTime ?? 0) - (lyric.beginTime ?? 0)),
                        in: &context
                    )
                } else {
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
    }
    
    func drawSpecial(
        slice: Text.Layout.RunSlice,
        beginTime: TimeInterval, endTime: TimeInterval,
        in context: inout GraphicsContext
    ) {
        let elapsedTime = self.elapsedTime - beginTime
        let duration = endTime - beginTime
        
        let unclampedProgress: Double = elapsedTime / duration
        let progress: Double = max(0, min(1, unclampedProgress))
        let softenProgress: Double = max(0, min(1, elapsedTime / (duration / softness)))
        
        let scale = 1.0 + sin(progress * .pi) * 0.2
        let glowRadius = sin(progress * .pi) * 10.0
        let opacity = sin(progress * .pi) * 0.8 + 0.5
        
        let bounds = slice.typographicBounds.rect
        let unclampedFilledWidth = bounds.width * CGFloat(unclampedProgress)
        let filledWidth = bounds.width * CGFloat(progress)
        let liftAmount = lift * damping(CGFloat(softenProgress))
        
        do {
            let mask = Path(.init(
                x: bounds.minX,
                y: bounds.minY,
                width: filledWidth + blendRadius / 2,
                height: bounds.height
            ))
            
            var context = context
            context.addFilter(.shadow(color: shadowColor, radius: shadowRadius))
            
            context.translateBy(x: bounds.midX, y: bounds.midY)
            context.scaleBy(x: scale, y: scale)
            context.translateBy(x: -bounds.midX, y: -bounds.midY)
            
            let shadowFilter = GraphicsContext.Filter.shadow(
                color: Color.white.opacity(opacity),
                radius: glowRadius,
                x: 0,
                y: 0
            )
            context.addFilter(shadowFilter)
            
            context.clipToLayer { context in
                context.fill(mask, with: .linearGradient(
                    .init(colors: [.white, .white.opacity(0.1)]),
                    startPoint: .init(x: bounds.minX + unclampedFilledWidth - blendRadius / 2, y: 0),
                    endPoint: .init(x: bounds.minX + unclampedFilledWidth + blendRadius / 2, y: 0)
                ))
            }
            
            context.translateBy(x: 0, y: -liftAmount)
            context.addFilter(.brightness(Double(brightness) * progress))
            context.draw(slice)
        }
    }
    
    func draw(
        slice: Text.Layout.RunSlice,
        beginTime: TimeInterval, endTime: TimeInterval,
        in context: inout GraphicsContext
    ) {
        let elapsedTime = self.elapsedTime - beginTime
        let duration = endTime - beginTime
        
        let unclampedProgress: Double = elapsedTime / duration
        let progress: Double = max(0, min(1, unclampedProgress))
        let softenProgress: Double = max(0, min(1, elapsedTime / (duration / softness)))
        
        let bounds = slice.typographicBounds.rect
        let unclampedFilledWidth = bounds.width * CGFloat(unclampedProgress)
        let filledWidth = bounds.width * CGFloat(progress)
        let liftAmount = lift * damping(CGFloat(softenProgress))
        
        do {
            var context = context
            
            context.translateBy(x: 0, y: -liftAmount)
            context.opacity = inactiveOpacity
            context.draw(slice)
        }
        
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
            
            context.translateBy(x: 0, y: -liftAmount)
            context.addFilter(.brightness(Double(brightness) * progress))
            
            context.draw(slice)
        }
    }
    
    private func damping(_ t: CGFloat, stiffness: CGFloat = 1, ratio: CGFloat = 0.5) -> CGFloat {
        guard t >= 0, t <= 1 else { return t }
        
        let omega0 = sqrt(stiffness)
        let dampingCoeff = 2 * ratio * omega0
        let expDecay = exp(-dampingCoeff * t)
        let oscillation = cos(omega0 * sqrt(1 - pow(ratio, 2)) * t)
        
        return 1 - expDecay * oscillation
    }
}
