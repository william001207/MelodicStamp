//
//  Defaults+LyricsMaxWidth.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/16.
//

import Defaults
import Foundation

extension Defaults {
    struct LyricsMaxWidth {
        var value: Double
    }
}

extension Double {
    init(_ lyricsMaxWidth: Defaults.LyricsMaxWidth) {
        self = lyricsMaxWidth.value
    }
}

extension Defaults.LyricsMaxWidth: ExpressibleByFloatLiteral, Comparable {
    init(floatLiteral value: Double) {
        self.value = value
    }

    static func < (lhs: Defaults.LyricsMaxWidth, rhs: Defaults.LyricsMaxWidth) -> Bool {
        lhs.value < rhs.value
    }
}

extension Defaults.LyricsMaxWidth: Clampable {
    static var range: ClosedRange<Self> {
        128.0...4096.0
    }
}

extension Defaults.LyricsMaxWidth: Codable, Defaults.Serializable {}
