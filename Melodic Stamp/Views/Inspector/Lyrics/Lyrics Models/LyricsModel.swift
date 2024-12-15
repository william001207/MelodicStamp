//
//  LyricsModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder
import SwiftSoup

// MARK: - Lyric Line (Protocol)

protocol LyricLine: Equatable, Hashable, Identifiable {
    var beginTime: TimeInterval? { get }
    var endTime: TimeInterval? { get }

    var isValid: Bool { get }
}

extension LyricLine {
    var isValid: Bool {
        beginTime != nil || endTime != nil
    }
}

// MARK: - Lyrics Parser (Protocol)

protocol LyricsParser {
    associatedtype Line: LyricLine

    var lines: [Line] { get set }

    init(string: String) throws

    func find(at time: TimeInterval) -> IndexSet
}

// MARK: Lyrics Type

enum LyricsType: String, Hashable, Identifiable, CaseIterable {
    case raw // Raw splitted string, unparsed
    case lrc // Line based
    case ttml // Word based

    var id: String {
        rawValue
    }
}

// MARK: Lyrics Storage

enum LyricsStorage {
    case raw(parser: RawLyricsParser)
    case lrc(parser: LRCParser)
    case ttml(parser: TTMLParser)

    var type: LyricsType {
        switch self {
        case .raw: .raw
        case .lrc: .lrc
        case .ttml: .ttml
        }
    }

    func find(at time: TimeInterval) -> IndexSet {
        switch self {
        case let .raw(parser):
            parser.find(at: time)
        case let .lrc(parser):
            parser.find(at: time)
        case let .ttml(parser):
            parser.find(at: time)
        }
    }
}

// MARK: Lyrics Model

@Observable class LyricsModel {
    private(set) var storage: LyricsStorage?
    private(set) var url: URL?
    var type: LyricsType?

    private var cache: String?

    func identify(url: URL?) {
        self.url = url
    }

    func load(string: String?, autoRecognizes: Bool = true) {
        if autoRecognizes {
            if let string {
                do {
                    type = try recognize(string: string) ?? .raw
                } catch {
                    type = .raw
                }
            } else {
                type = nil
            }
        }
        
        // Debounce
        guard type != storage?.type || string != cache || url != url else { return }

        cache = string
        url = url
        guard let string else {
            storage = nil
            return
        }

        if let type {
            do {
                storage = switch type {
                case .raw:
                    try .raw(parser: .init(string: string))
                case .lrc:
                    try .lrc(parser: .init(string: string))
                case .ttml:
                    try .ttml(parser: .init(string: string))
                }
            } catch {
                storage = nil
            }
        }
    }

    func find(at time: TimeInterval, in url: URL?) -> IndexSet {
        guard let storage, let url, url == self.url else { return [] }
        return storage.find(at: time)
    }
}

extension LyricsModel {
    func recognize(string: String?) throws -> LyricsType? {
        guard let string else { return nil }
        return if string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .starts(with: /\[.+].*/)
        {
            .lrc
        } else if
            let body = try SwiftSoup.parse(string).body(),
            body.tagName() == "tt"
        {
            .ttml
        } else {
            .raw
        }
    }
}
