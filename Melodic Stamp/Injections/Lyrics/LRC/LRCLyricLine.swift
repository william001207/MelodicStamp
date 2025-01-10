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

    let id: UUID = .init()

    var beginTime: TimeInterval?
    var endTime: TimeInterval?

    var tags: [LRCTag] = []
    var content: String
    var translation: String?
}

extension LRCLyricLine {
    var attachments: LyricAttachments {
        var attachments: LyricAttachments = []

        if translation != nil {
            attachments.formUnion(.translation)
        }

        return attachments
    }
}
