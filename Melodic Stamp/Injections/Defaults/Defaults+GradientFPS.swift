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
        var value: Int
    }
}

extension Int {
    init(_ gradientFPS: Defaults.GradientFPS) {
        self = gradientFPS.value
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
    static let range: ClosedRange<Self> = 30...120
}

extension Defaults.GradientFPS: Codable, Defaults.Serializable {}
