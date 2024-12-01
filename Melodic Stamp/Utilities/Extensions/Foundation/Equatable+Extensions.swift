//
//  Equatable+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import Foundation

extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return other.isExactlyEqual(self)
        }
        return self == other
    }

    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

func areEqual(_ first: Any, _ second: Any) -> Bool {
    guard
        let equatableOne = first as? any Equatable,
        let equatableTwo = second as? any Equatable
    else { return false }

    return equatableOne.isEqual(equatableTwo)
}
