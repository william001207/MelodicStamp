//
//  LRCParser.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder

@Observable class LRCParser: LyricsParser {
    typealias Tag = LRCTag
    typealias Line = LRCLyricLine

    var lines: [LRCLyricLine] = []

    required init(string: String) throws {
        try parse(string: string)
    }

    private func parse(string: String) throws {
        var lines: [LRCLyricLine] = []

        let contents = string
            .split(separator: .newlineSequence)
            .map(String.init)

        for content in contents {
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

            guard let match = try lineRegex.wholeMatch(
                in: content.trimmingCharacters(in: .whitespacesAndNewlines)
            ) else { return }
            // Output: (original, tagString, _, content)

            let tagString = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            let content = String(match.output.3).trimmingCharacters(in: .whitespacesAndNewlines)

            var tags: [String] = []
            for match in tagString.matches(of: tagRegex) {
                tags.append(String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines))
            }

            var line: LRCLyricLine = .init(content: content)
            
            for tag in tags {
                if let time = try TimeInterval(lyricTimestamp: tag) {
                    // Parse timestamp
                    if line.beginTime == nil {
                        // Save as start time
                        line.beginTime = time
                    } else if line.endTime == nil {
                        // Save as end time
                        line.endTime = time
                    }
                } else {
                    // Parse tag
                    do {
                        if let tag = try Self.parseTag(string: tag) {
                            line.tags.append(tag)
                        }
                    } catch {}
                }
            }

            let isTranslation = line.tags.map(\.type).contains(.translation)
            if isTranslation {
                // Append translation to last line
                
                let lastIndex = lines.endIndex - 1
                guard lines.indices.contains(lastIndex) else { continue }
                
                lines[lastIndex].translation = line.content
            } else {
                lines.append(line)
            }
        }
        
        self.lines = lines
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
