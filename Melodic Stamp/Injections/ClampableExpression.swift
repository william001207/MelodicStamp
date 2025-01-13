//
//  ClampableExpression.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

protocol ClampableExpression: Comparable {
    static func clamp(_ value: Self, to: ClosedRange<Self>) -> Self

    func clamp(to: ClosedRange<Self>) -> Self
}

extension ClampableExpression {
    static func clamp(_ value: Self, to range: ClosedRange<Self>) -> Self {
        min(range.upperBound, max(range.lowerBound, value))
    }

    func clamp(to range: ClosedRange<Self>) -> Self {
        Self.clamp(self, to: range)
    }
}

protocol Clampable: ClampableExpression {
    static var range: ClosedRange<Self> { get }

    static func clamp(_ value: Self) -> Self

    init(clamping value: Self)

    var clamped: Self { get }
}

extension Clampable {
    static func clamp(_ value: Self) -> Self {
        clamp(value, to: range)
    }

    init(clamping value: Self) {
        self = value.clamped
    }

    var clamped: Self {
        Self.clamp(self)
    }
}

protocol DynamicClampable: ClampableExpression {
    var dynamicRange: ClosedRange<Self> { get }

    var dynamicallyClamped: Self { get }
}

extension DynamicClampable {
    var dynamicallyClamped: Self {
        Self.clamp(self, to: dynamicRange)
    }
}
