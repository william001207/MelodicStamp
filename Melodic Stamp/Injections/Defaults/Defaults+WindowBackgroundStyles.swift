//
//  Defaults+WindowBackgroundStyles.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    enum MainWindowBackgroundStyle: String, Equatable, Hashable, Identifiable, Codable, Serializable {
        case opaque
        case vibrant

        var id: Self { self }
    }

    enum MiniPlayerBackgroundStyle: String, Equatable, Hashable, Identifiable, Codable, Serializable {
        case opaque
        case vibrant
        case dynamicallyTinted

        var id: Self { self }
    }
}
