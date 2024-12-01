//
//  TTMLLyricsParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

struct TTMLLyricLine: LyricLine {
    var startTime: TimeInterval
    var endTime: TimeInterval?
    var content: String
}

@Observable class TTMLLyricsParser: LyricsParser {
    typealias Line = TTMLLyricLine
    
    var tags: [LyricTag]
    var lines: [TTMLLyricLine]
    
    required init(string: String) throws {
        // TODO: parse ttml lyrics
        fatalError()
    }
}
