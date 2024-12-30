//
//  Text+Extensions.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

extension Text.Layout {
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }

    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        flatMap(\.self)
    }
}

extension Text.Layout: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isTruncated)
        for flattenedRun in flattenedRuns {
            hasher.combine(flattenedRun)
        }
    }
}

extension Text.Layout.Run: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(layoutDirection)
        hasher.combine(typographicBounds)
        hasher.combine(characterIndices)
    }
}

extension Text.Layout.RunSlice: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(run)
        hasher.combine(indices)
    }
}

extension Text.Layout.TypographicBounds: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(width)
        hasher.combine(ascent)
        hasher.combine(descent)
        hasher.combine(leading)
    }
}
