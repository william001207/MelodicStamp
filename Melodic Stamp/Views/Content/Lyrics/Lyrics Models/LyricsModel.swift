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

    var type: LyricsType {
        switch self {
        case .raw: .raw
        case .lrc: .lrc
        case .ttml: .ttml
        }
    }
}

// MARK: Lyrics Model

@Observable class LyricsModel {
    private(set) var storage: LyricsStorage?
    var type: LyricsType = .raw

    private var cache: String?

    func load(string: String?) throws {
        // debounce
        guard type != storage?.type || string != cache else { return }

        cache = string
        guard let string else {
            storage = nil
            return
        }

        storage = switch type {
        case .raw:
            try .raw(parser: .init(string: string))
        case .lrc:
            try .lrc(parser: .init(string: string))
        case .ttml:
            try .ttml(parser: .init(string: string))
        }
    }
}
