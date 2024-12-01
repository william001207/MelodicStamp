//
//  LyricsModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder

struct LyricTag {
    enum LyricTagType: String, CaseIterable {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creator = "by"
        case offset
        case editor = "re"
        case version = "ve"
        
        static var regex: Regex<Substring> {
            Regex {
                ChoiceOf {
                    artist.rawValue
                    album.rawValue
                    title.rawValue
                    author.rawValue
                    length.rawValue
                    creator.rawValue
                    offset.rawValue
                    editor.rawValue
                    version.rawValue
                }
            }
        }
    }
    
    var type: LyricTagType
    var content: String
    
    init(type: LyricTagType, content: String) {
        self.type = type
        self.content = content
    }
    
    init?(string: String) throws {
        let regex = Regex {
            "["
            Capture {
                LyricTagType.regex
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
        
        guard let type = LyricTagType(rawValue: key) else { return nil }
        self.type = type
        self.content = value
    }
}

enum LyricType {
    case raw // raw string, unparsed
    case lrc(LRCLyricsParser) // sentence based
    case ttml(TTMLLyricsParser) // word based
}

protocol LyricsParser {
    associatedtype Line: LyricLine
    
    var tags: [LyricTag] { get set }
    var lines: [Line] { get set }
    
    init(string: String) throws
}

protocol LyricLine: Equatable {
    var startTime: TimeInterval { get set }
    var endTime: TimeInterval? { get set }
    var content: String { get set }
}

@Observable class LyricsModel {
    var string: String = ""
}
