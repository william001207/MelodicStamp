//
//  LRCLyricLine.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

struct LRCLyricLine: LyricLine, AnimatedString {
    typealias Tag = LRCTag

    enum LRCLyricType: Hashable, Equatable {
        case main
        case translation
    }

    let id: UUID = .init()

    var type: LRCLyricType = .main
    var beginTime: TimeInterval?
    var endTime: TimeInterval?

    var tags: [LRCTag] = []
    var content: String
    var translation: String?
}
