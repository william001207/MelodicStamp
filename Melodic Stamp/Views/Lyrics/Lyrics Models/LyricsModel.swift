//
//  LyricsModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder

struct LyricTag: Identifiable {
    enum LyricTagType: String, Identifiable, CaseIterable {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creator = "by"
        case offset
        case editor = "re"
        case version = "ve"
        
        var id: String {
            rawValue
        }
        
        var isMetadata: Bool {
            switch self {
            case .length, .offset: true
            default: false
            }
        }
        
        var name: String {
            switch self {
            case .artist: .init(localized: "Artist")
            case .album: .init(localized: "Album")
            case .title: .init(localized: "Title")
            case .author: .init(localized: "Author")
            case .length: .init(localized: "Length")
            case .creator: .init(localized: "Creator")
            case .offset: .init(localized: "Offset")
            case .editor: .init(localized: "Editor")
            case .version: .init(localized: "Version")
            }
        }
        
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
    
    var id: LyricTagType {
        type
    }
    
    var type: LyricTagType
    var content: String
}

protocol LyricsParser {
    associatedtype Line: LyricLine
    
    var tags: [LyricTag] { get set }
    var lines: [Line] { get set }
    
    init(string: String) throws
}

protocol LyricLine: Equatable, Hashable, Identifiable {
    var startTime: TimeInterval? { get set }
    var endTime: TimeInterval? { get set }
    var content: String { get set }
}

enum LyricsType: String, CaseIterable {
    case raw // raw splitted string, unparsed
    case lrc // sentence based
    case ttml // word based
}

enum LyricsStorage {
    case raw(parser: RawLyricsParser)
    case lrc(parser: LRCLyricsParser)
    case ttml(parser: TTMLLyricsParser)
}

@Observable class LyricsModel {
    private(set) var storage: LyricsStorage?
    
    func load(type: LyricsType = .raw, string: String?) throws {
        guard let string else {
            self.storage = nil
            return
        }
        
        self.storage = switch type {
        case .raw:
                .raw(parser: try .init(string: string))
        case .lrc:
                .lrc(parser: try .init(string: string))
        case .ttml:
                .ttml(parser: try .init(string: string))
        }
    }
}
