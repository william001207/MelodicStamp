//
//  LRCLyricsParser.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation

struct LRCLyricLine: LyricLine {
    enum LRCLyricType: Equatable {
        case main
        case translation
    }
    
    var type: LRCLyricType = .main
    var startTime: TimeInterval
    var endTime: TimeInterval?
    var content: String
}

@Observable class LRCLyricsParser: LyricsParser {
    typealias Line = LRCLyricLine
    
    var tags: [LyricTag]
    var lines: [LRCLyricLine]
    
    required init(string: String) throws {
        self.tags = []
        self.lines = []
        
        try string.split(separator: "\n").map(String.init(_:)).forEach {
            var content = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            var headers: [String] = []
            
            while content.starts(with: "["), content.contains("]") {
                let header = String(content.extractNearest(from: "[", to: "]"))
                headers.append(header)
                content = String(content.extractNearest(from: "]"))
            }
            
            var line: LRCLyricLine?
            for header in headers {
                if let time = try TimeInterval(lyricTimestamp: header) {
                    // parse timestamp
                    if line == nil {
                        let isTranslation = header.starts(with: "tr:")
                        // save as start time
                        line = .init(type: isTranslation ? .translation : .main, startTime: time, content: content)
                    } else {
                        // save as end time or drop
                        line?.endTime = time
                    }
                } else {
                    // parse tag
                    do {
                        if let tag = try LyricTag(string: header) {
                            tags.append(tag)
                        }
                    } catch {
                        
                    }
                }
            }
            
            if let line {
                lines.append(line)
            }
        }
    }
}
