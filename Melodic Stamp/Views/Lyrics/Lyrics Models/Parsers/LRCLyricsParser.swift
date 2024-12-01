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

        let contents =
            string
            .split(separator: .newlineSequence)
            .map(String.init(_:))

        try contents.forEach {
            let headerRegex = Regex {
                "["
                Capture {
                    OneOrMore(.anyNonNewline, .reluctant)
                }
                "]"
            }
            let lineRegex = Regex {
                Capture {
                    ZeroOrMore {
                        headerRegex
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
            // output: (original, headerString, _, content)
            
            let headersString = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            let content = String(match.output.3).trimmingCharacters(in: .whitespacesAndNewlines)

            var headers: [String] = []
            for match in headersString.matches(of: headerRegex) {
                headers.append(String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            print("Extracting lyric line: \(headers), \"\(content)\"")

            var line: LRCLyricLine = .init(content: content)

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

            if !line.isEmpty {
                lines.append(line)
            }
        }
    }

    static func parseTag(string: String) throws -> LyricTag? {
        let regex = Regex {
            Capture {
                LyricTag.LyricTagType.regex
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

        guard let type = LyricTag.LyricTagType(rawValue: key) else {
            return nil
        }
        return .init(type: type, content: value)
    }
}
