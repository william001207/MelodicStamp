//
//  Defaults+BackgroundStyles.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import Foundation

extension Defaults {
    enum MainWindowBackgroundStyle: String, Equatable, Hashable, CaseIterable, Identifiable, Codable, Serializable {
        case opaque
        case vibrant
        case ethereal

        var id: Self { self }
    }

    enum MiniPlayerBackgroundStyle: String, Equatable, Hashable, CaseIterable, Identifiable, Codable, Serializable {
        case opaque
        case vibrant
        case ethereal
        case chroma

        var id: Self { self }
    }
}
