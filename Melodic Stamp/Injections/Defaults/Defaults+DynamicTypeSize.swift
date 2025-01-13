//
//  Defaults+DynamicTypeSize.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import Defaults
import SwiftUI

extension Defaults {
    typealias DynamicTypeSize = SwiftUI.DynamicTypeSize
}

extension Defaults.DynamicTypeSize: @retroactive RawRepresentable {
    public init?(rawValue: Int) {
        guard Self.allCases.indices.contains(rawValue) else { return nil }
        self = Self.allCases[rawValue]
    }
    
    public var rawValue: Int {
        Self.allCases.firstIndex(of: self)!
    }
}

extension Defaults.DynamicTypeSize: Defaults.Serializable {}

extension Defaults.DynamicTypeSize: DynamicClampable {
    var range: ClosedRange<DynamicTypeSize> {
        Defaults[.lyricsTypeSizes]
    }
}
