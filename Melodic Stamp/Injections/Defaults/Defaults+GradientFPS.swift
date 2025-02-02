//
//  Defaults+GradientFPS.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    struct GradientFPS {
        var value: Int {
            didSet {
                let clamped = clamped.value
                guard value != clamped else { return }
                value = clamped
            }
        }
    }
}

extension Int {
    init(_ gradientFPS: Defaults.GradientFPS) {
        self = gradientFPS.clamped.value
    }
}

extension Defaults.GradientFPS: ExpressibleByIntegerLiteral, Comparable {
    init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }

    static func < (lhs: Defaults.GradientFPS, rhs: Defaults.GradientFPS) -> Bool {
        lhs.value < rhs.value
    }
}

extension Defaults.GradientFPS: Clampable {
    static let range: ClosedRange<Self> = 30...240
}

extension Defaults.GradientFPS: Codable, Defaults.Serializable {}
