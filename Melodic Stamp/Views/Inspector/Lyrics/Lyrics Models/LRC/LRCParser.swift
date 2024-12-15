//
//  LRCParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder

@Observable class LRCParser: LyricsParser {
    typealias Tag = LRCTag
    typealias Line = LRCLine

    var lines: [LRCLine] = []

    required init(string: String) throws {
        try parse(from: string)
    }
    
    private func parse(from string: String) throws {
        self.lines = []
        
        let contents = string
            .split(separator: .newlineSequence)
            .map(String.init(_:))
        
        try contents.forEach {
            let tagRegex = Regex {
                "["
                Capture {
                    OneOrMore(.anyNonNewline, .reluctant)
                }
                "]"
            }
            let lineRegex = Regex {
                Capture {
                    ZeroOrMore {
                        tagRegex
                    }
                }
                Capture {
                    ZeroOrMore(.anyNonNewline)
                }
            }
            
            guard
                let match = try lineRegex.wholeMatch(
                    in: $0.trimmingCharacters(in: .whitespacesAndNewlines))
            else { return }
            // Output: (original, tagString, _, content)
            
            let tagString = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            let content = String(match.output.3).trimmingCharacters(in: .whitespacesAndNewlines)
            
            var tags: [String] = []
            for match in tagString.matches(of: tagRegex) {
                tags.append(String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            print("Extracting lyric line: \(tags), \"\(content)\"")
            
            var line: LRCLine = .init(content: content)
            
            for tag in tags {
                if let time = try TimeInterval(lyricTimestamp: tag) {
                    // Parse timestamp
                    if line.startTime == nil {
                        // Save as start time
                        line.startTime = time
                    } else if line.endTime == nil {
                        // Save as end time
                        line.endTime = time
                    }
                } else {
                    // Parse tag
                    do {
                        if let tag = try Self.parseTag(string: tag) {
                            if tag.type.isMetadata {
                                switch tag.type {
                                case .translation:
                                    line.type = .translation(locale: tag.content)
                                default:
                                    // TODO: Handle more metadatas
                                    break
                                }
                            } else {
                                line.tags.append(tag)
                            }
                        }
                    } catch {}
                }
            }
            
            lines.append(line)
        }
    }

    func find(at time: TimeInterval) -> IndexSet {
        var nearestStartTime: TimeInterval = .zero
        var indices: IndexSet = []

        for startTime in lines.compactMap(\.startTime) {
            guard startTime <= time, startTime >= nearestStartTime else { continue }
            nearestStartTime = startTime
        }

        for (index, line) in lines.enumerated() {
            guard let startTime = line.startTime, startTime <= time, startTime >= nearestStartTime else { continue }

            if let endTime = line.endTime {
                guard endTime > time else { continue }
                indices.insert(index)
            } else {
                indices.insert(index)
            }
        }

        return indices
    }

    static func parseTag(string: String) throws -> Tag? {
        let regex = Regex {
            Capture {
                Tag.TagType.regex
            }
            ":"
            Capture {
                OneOrMore {
                    CharacterClass(.anyNonNewline)
                }
            }
        }

        guard let match = try regex.wholeMatch(in: string) else { return nil }
        let key = String(match.output.1)
        let value = String(match.output.2)

        guard let type = Tag.TagType(rawValue: key) else {
            return nil
        }
        return .init(type: type, content: value)
    }
}
