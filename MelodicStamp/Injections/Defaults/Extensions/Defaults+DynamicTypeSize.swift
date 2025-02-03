//
//  Defaults+DynamicTypeSize.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/16.
//

import Defaults
import SwiftUI

extension DynamicTypeSize: Defaults.Serializable {}

extension DynamicTypeSize: DynamicClampable {
    var dynamicRange: ClosedRange<DynamicTypeSize> {
        Defaults[.lyricsTypeSizes]
    }
}
