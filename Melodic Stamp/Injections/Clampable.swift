//
//  Clampable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

protocol Clampable: Comparable {
    static var range: ClosedRange<Self> { get }

    static func clamp(_ value: Self) -> Self

    init(clamping value: Self)

    var clamped: Self { get }
}

extension Clampable {
    static func clamp(_ value: Self) -> Self {
        min(range.upperBound, max(range.lowerBound, value))
    }

    init(clamping value: Self) {
        self = value.clamped
    }

    var clamped: Self {
        Self.clamp(self)
    }
}
