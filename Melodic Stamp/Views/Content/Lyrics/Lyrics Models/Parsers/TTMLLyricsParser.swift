//
//  TTMLLyricsParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

struct TTMLLyricLine: LyricLine {
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    var content: String

    let id: UUID = .init()
}

@Observable class TTMLLyricsParser: LyricsParser {
    typealias Line = TTMLLyricLine

    var lines: [TTMLLyricLine]

    required init(string _: String) throws {
        // TODO: handle ttml parse
        lines = []
    }
}
