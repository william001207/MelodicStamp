//
//  RawLyricsParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

@Observable class RawLyricsParser: LyricsParser {
    typealias Line = RawLyricLine

    var lines: [RawLyricLine]

    required init(string: String) throws {
        self.lines = string
            .split(separator: .newlineSequence)
            .map(String.init(_:))
            .map { .init(content: $0) }
    }

    func find(at _: TimeInterval) -> IndexSet {
        []
    }
}
