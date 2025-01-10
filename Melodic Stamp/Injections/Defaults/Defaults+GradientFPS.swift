//
//  Defaults+GradientFPS.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    typealias GradientFPS = Int
}

extension Defaults.GradientFPS: Clampable {
    static let range: ClosedRange<Int> = 30...120
}
