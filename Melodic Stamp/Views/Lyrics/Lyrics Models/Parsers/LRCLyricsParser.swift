//
//  LRCLyricsParser.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation
import RegexBuilder

struct LRCLyricLine: LyricLine {
    enum LRCLyricType: Equatable {
        case main
        case translation
    }
    
    var type: LRCLyricType = .main
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    var content: String
}

extension LRCLyricLine: Identifiable {
    var id: Int {
        hashValue
    }
}

@Observable class LRCLyricsParser: LyricsParser {
    typealias Line = LRCLyricLine
    
    var tags: [LyricTag]
    var lines: [LRCLyricLine]
    
    required init(string: String) throws {
        self.tags = []
        self.lines = []
        
        let contents = string
            .split(separator: .newlineSequence)
            .map(String.init(_:))
        
        try contents.forEach {
            var content = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            var headers: [String] = []
            
            while content.starts(with: "["), content.contains("]") {
                let header = String(content.extractNearest(from: "[", to: "]"))
                headers.append(header)
                content = String(content.extractNearest(from: "]"))
            }
            
            // TODO: handle translation
            let isTranslation = false
            var line: LRCLyricLine = .init(type: isTranslation ? .translation : .main, content: content)
            
            for header in headers {
                if let time = try TimeInterval(lyricTimestamp: header) {
                    // parse timestamp
                    if line.startTime == nil {
                        // save as start time
                        line.startTime = time
                    } else if line.endTime == nil {
                        // save as end time or drop
                        line.endTime = time
                    }
                } else {
                    // parse tag
                    do {
                        if let tag = try Self.parseTag(string: header) {
                            if tag.type.isMetadata {
                                // TODO: handle metadata
                            } else {
                                tags.append(tag)
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            
            lines.append(line)
        }
    }
    
    static func parseTag(string: String) throws -> LyricTag? {
        let regex = Regex {
            "["
            Capture {
                LyricTag.LyricTagType.regex
            }
            ":"
            Capture {
                OneOrMore {
                    CharacterClass(.anyNonNewline)
                }
            }
            "]"
        }
        
        guard let match = try regex.wholeMatch(in: string) else { return nil }
        let key = String(match.output.1), value = String(match.output.2)
        
        guard let type = LyricTag.LyricTagType(rawValue: key) else { return nil }
        return .init(type: type, content: value)
    }
}
