//
//  RangeExpression+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/16.
//

import Foundation

extension Range {
    func map<T>(_ transform: @escaping (Bound) throws -> T) rethrows -> Range<T> {
        let lowerBound = try transform(lowerBound)
        let upperBound = try transform(upperBound)
        return lowerBound ..< upperBound
    }
}

extension ClosedRange {
    func map<T>(_ transform: @escaping (Bound) throws -> T) rethrows -> ClosedRange<T> {
        let lowerBound = try transform(lowerBound)
        let upperBound = try transform(upperBound)
        return lowerBound...upperBound
    }
}

extension PartialRangeFrom {
    func map<T>(_ transform: @escaping (Bound) throws -> T) rethrows -> PartialRangeFrom<T> {
        let lowerBound = try transform(lowerBound)
        return lowerBound...
    }
}

extension PartialRangeUpTo {
    func map<T>(_ transform: @escaping (Bound) throws -> T) rethrows -> PartialRangeUpTo<T> {
        let upperBound = try transform(upperBound)
        return ..<upperBound
    }
}

extension PartialRangeThrough {
    func map<T>(_ transform: @escaping (Bound) throws -> T) rethrows -> PartialRangeThrough<T> {
        let upperBound = try transform(upperBound)
        return ...upperBound
    }
}
