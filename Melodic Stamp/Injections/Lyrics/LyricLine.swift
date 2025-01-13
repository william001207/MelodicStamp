//
//  LyricLine.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

protocol LyricLine: Equatable, Hashable, Identifiable {
    var beginTime: TimeInterval? { get }
    var endTime: TimeInterval? { get }
    var content: String { get }

    var isValid: Bool { get }
    var attachments: LyricsAttachments { get }
}

extension LyricLine {
    var isValid: Bool {
        beginTime != nil || endTime != nil
    }

    var attachments: LyricsAttachments { [] }
}
