//
//  Defaults+GradientDynamics.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    enum GradientDynamics: String, Equatable, Hashable, CaseIterable, Identifiable, Codable, Serializable {
        case plain
        case binary
        case ternary

        var id: Self { self }
    }
}
