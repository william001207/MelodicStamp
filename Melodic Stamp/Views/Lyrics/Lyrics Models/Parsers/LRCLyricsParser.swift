//
//  LRCLyricsParser.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation
import RegexBuilder

struct LRCLyricTag: Hashable, Identifiable, Equatable {
    enum LyricTagType: String, Hashable, Identifiable, Equatable, CaseIterable {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creator = "by"
        case offset
        case editor = "re"
        case version = "ve"
        case translation = "tr"
        
        var id: String {
            rawValue
        }
        
        var isMetadata: Bool {
            switch self {
            case .length, .offset, .translation: true
            default: false
            }
        }
        
        var name: String {
            switch self {
            case .length: .init(localized: "Length")
            case .offset: .init(localized: "Offset")
            case .translation: .init(localized: "Translation")
                
            case .artist: .init(localized: "Artist")
            case .album: .init(localized: "Album")
            case .title: .init(localized: "Title")
            case .author: .init(localized: "Author")
            case .creator: .init(localized: "Creator")
            case .editor: .init(localized: "Editor")
            case .version: .init(localized: "Version")
            }
        }
        
        static var regex: Regex<Substring> {
            Regex {
                ChoiceOf {
                    length.rawValue
                    offset.rawValue
                    translation.rawValue
                    
                    artist.rawValue
                    album.rawValue
                    title.rawValue
                    author.rawValue
                    creator.rawValue
                    editor.rawValue
                    version.rawValue
                }
            }
        }
    }
    
    var id: LyricTagType {
        type
    }
    
    var type: LyricTagType
    var content: String
}

struct LRCLyricLine: LyricLine {
    typealias Tag = LRCLyricTag
    
    enum LRCLyricType: Hashable, Equatable {
        case main
        case translation(locale: String)
    }
    
    let id: UUID = .init()

    var type: LRCLyricType = .main
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    
    var tags: [LRCLyricTag] = []
    var content: String
}

@Observable class LRCLyricsParser: LyricsParser {
    typealias Tag = LRCLyricTag
    typealias Line = LRCLyricLine

    var lines: [LRCLyricLine]

    required init(string: String) throws {
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
            // output: (original, tagString, _, content)
            
            let tagString = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            let content = String(match.output.3).trimmingCharacters(in: .whitespacesAndNewlines)

            var tags: [String] = []
            for match in tagString.matches(of: tagRegex) {
                tags.append(String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            print("Extracting lyric line: \(tags), \"\(content)\"")

            var line: LRCLyricLine = .init(content: content)

            for tag in tags {
                if let time = try TimeInterval(lyricTimestamp: tag) {
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
                        if let tag = try Self.parseTag(string: tag) {
                            if tag.type.isMetadata {
                                switch tag.type {
                                case .translation:
                                    line.type = .translation(locale: tag.content)
                                default:
                                    // TODO: handle more metadatas
                                    break
                                }
                            } else {
                                line.tags.append(tag)
                            }
                        }
                    } catch {

                    }
                }
            }

            lines.append(line)
        }
    }

    static func parseTag(string: String) throws -> Tag? {
        let regex = Regex {
            Capture {
                Tag.LyricTagType.regex
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

        guard let type = Tag.LyricTagType(rawValue: key) else {
            return nil
        }
        return .init(type: type, content: value)
    }
}
