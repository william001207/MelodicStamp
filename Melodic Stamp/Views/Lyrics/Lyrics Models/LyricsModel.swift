//
//  LyricsModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder

// MARK: - Lyric Line (Protocol)

protocol LyricLine: Equatable, Hashable, Identifiable {
    var startTime: TimeInterval? { get set }
    var endTime: TimeInterval? { get set }
    var content: String { get set }
    
    var isValid: Bool { get }
}

extension LyricLine {
    var isValid: Bool {
        startTime != nil || endTime != nil
    }
}

// MARK: - Lyrics Parser (Protocol)

protocol LyricsParser {
    associatedtype Line: LyricLine
    
    var lines: [Line] { get set }
    
    init(string: String) throws
}

// MARK: Lyrics Type

enum LyricsType: String, Hashable, Identifiable, CaseIterable {
    case raw // raw splitted string, unparsed
    case lrc // sentence based
    case ttml // word based
    
    var id: String {
        rawValue
    }
}

// MARK: Lyrics Storage

enum LyricsStorage {
    case raw(parser: RawLyricsParser)
    case lrc(parser: LRCLyricsParser)
    case ttml(parser: TTMLLyricsParser)
}

// MARK: Lyrics Model

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
