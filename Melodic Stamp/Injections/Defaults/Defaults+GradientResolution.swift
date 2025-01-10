//
//  Defaults+GradientResolution.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    typealias GradientResolution = Double
}

extension Defaults.GradientResolution: Clampable {
    static let range: ClosedRange<Double> = 0.0...1.0
}
