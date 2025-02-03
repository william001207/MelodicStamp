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
        case quaternion

        var id: Self { self }

        var canAnimateWithAudio: Bool {
            switch self {
            case .plain: false
            default: true
            }
        }

        var count: Int {
            switch self {
            case .plain: 1
            case .binary: 2
            case .ternary: 3
            case .quaternion: 4
            }
        }
    }
}
