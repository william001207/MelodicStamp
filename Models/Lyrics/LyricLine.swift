//
//  LyricLine.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

protocol LyricLine: Equatable, Hashable, Identifiable {
    /// The most tolerant beginning time, which should cover the widest time range where this line is eligible for displaying.
    var beginTime: TimeInterval? { get }
    /// The most tolerant ending time, which should cover the widest time range where this line is eligible for displaying.
    var endTime: TimeInterval? { get }

    /// The most condensed beginning time, typically used for identifying whether this line is eligible for highlighting.
    var condensedBeginTime: TimeInterval? { get }
    /// The most condensed ending time, typically used for identifying whether this line is eligible for highlighting.
    var condensedEndTime: TimeInterval? { get }

    /// The ``String`` content for this line, which can be lossy yet descriptive.
    var content: String { get }

    var isValid: Bool { get }
    var attachments: LyricsAttachments { get }
}

extension LyricLine {
    var condensedBeginTime: TimeInterval? { beginTime }
    var condensedEndTime: TimeInterval? { endTime }

    var isValid: Bool {
        beginTime != nil || endTime != nil
    }

    var attachments: LyricsAttachments { [] }
}
