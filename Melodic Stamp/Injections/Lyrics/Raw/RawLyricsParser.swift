//
//  RawLyricsParser.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

@Observable final class RawLyricsParser: LyricsParser {
    typealias Line = RawLyricLine

    var lines: [RawLyricLine]

    required init(string: String) throws {
        self.lines = string
            .split(separator: .newlineSequence)
            .map(String.init)
            .map { .init(content: $0) }
    }
}

extension RawLyricsParser: Equatable {
    static func == (lhs: RawLyricsParser, rhs: RawLyricsParser) -> Bool {
        lhs.lines == rhs.lines
    }
}

extension RawLyricsParser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(lines)
    }
}
