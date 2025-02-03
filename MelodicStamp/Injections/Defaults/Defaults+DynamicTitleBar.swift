//
//  Defaults+DynamicTitleBar.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import Foundation

extension Defaults {
    enum DynamicTitleBar: String, Hashable, Equatable, CaseIterable, Identifiable, Codable, Serializable {
        case never
        case always
        case whilePlaying

        var id: Self { self }
    }
}
