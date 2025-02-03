//
//  DynamicTypeSize+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/9.
//

import SwiftUI

extension DynamicTypeSize: @retroactive Strideable {
    public typealias Stride = Int

    public func distance(to other: DynamicTypeSize) -> Int {
        let selfIndex = Self.allCases.firstIndex(of: self)!
        let otherIndex = Self.allCases.firstIndex(of: other)!
        return otherIndex.distance(to: selfIndex)
    }

    public func advanced(by n: Int) -> DynamicTypeSize {
        let index = Self.allCases.firstIndex(of: self)!
        let targetIndex = index.advanced(by: n)
        let clampedTargetIndex = max(Self.allCases.indices.lowerBound, min(Self.allCases.indices.upperBound - 1, targetIndex))
        return Self.allCases[clampedTargetIndex]
    }
}

extension DynamicTypeSize {
    static postfix func ++ (lhs: inout DynamicTypeSize) {
        lhs = lhs.advanced(by: 1)
    }

    static postfix func -- (lhs: inout DynamicTypeSize) {
        lhs = lhs.advanced(by: -1)
    }
}

infix operator +~: AdditionPrecedence
infix operator -~: AdditionPrecedence
extension DynamicTypeSize {
    static func +~ (lhs: inout DynamicTypeSize, rhs: DynamicTypeSize) {
        lhs = min(lhs.advanced(by: 1), rhs)
    }

    static func -~ (lhs: inout DynamicTypeSize, rhs: DynamicTypeSize) {
        lhs = max(lhs.advanced(by: -1), rhs)
    }
}

extension DynamicTypeSize {
    var scale: CGFloat {
        switch self {
        case .xSmall: 0.5
        case .small: 0.6
        case .medium: 0.8
        case .large: 1
        case .xLarge: 1.15
        case .xxLarge: 1.275
        case .xxxLarge: 1.35
        case .accessibility1: 1.5
        case .accessibility2: 1.75
        case .accessibility3: 2
        case .accessibility4: 2.1
        case .accessibility5: 2.2
        default: 1
        }
    }
}

extension DynamicTypeSize {
    static var minimum: DynamicTypeSize { allCases.min()! }
    static var maximum: DynamicTypeSize { allCases.max()! }
}

extension DynamicTypeSize: @retroactive RawRepresentable {
    public init?(rawValue: Int) {
        guard Self.allCases.indices.contains(rawValue) else { return nil }
        self = Self.allCases[rawValue]
    }

    public var rawValue: Int {
        Self.allCases.firstIndex(of: self)!
    }
}
