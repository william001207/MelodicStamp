//
//  Defaults+GradientResolution.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    struct GradientResolution {
        var value: Double
    }
}

extension Double {
    init(_ gradientResolution: Defaults.GradientResolution) {
        self = gradientResolution.value
    }
}

extension Defaults.GradientResolution: ExpressibleByFloatLiteral, Comparable {
    init(floatLiteral value: Double) {
        self.value = value
    }

    static func < (lhs: Defaults.GradientResolution, rhs: Defaults.GradientResolution) -> Bool {
        lhs.value < rhs.value
    }
}

extension Defaults.GradientResolution: Clampable {
    static let range: ClosedRange<Self> = 0.0...1.0
}

extension Defaults.GradientResolution: Codable, Defaults.Serializable {}
