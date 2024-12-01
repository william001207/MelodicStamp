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
    
    func find(at time: TimeInterval) -> IndexSet
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
    
    func find(at time: TimeInterval) -> IndexSet {
        switch self {
        case .raw(let parser):
            parser.find(at: time)
        case .lrc(let parser):
            parser.find(at: time)
        case .ttml(let parser):
            parser.find(at: time)
        }
    }
}

// MARK: Lyrics Model

@Observable class LyricsModel {
    private(set) var storage: LyricsStorage?
    private(set) var url: URL?
    var type: LyricsType = .raw

    private var cache: String?
    
    func identify(url: URL?) {
        self.url = url
    }

    func load(string: String?) {
        // debounce
        guard type != storage?.type || string != cache || url != self.url else { return }

        cache = string
        self.url = url
        guard let string else {
            storage = nil
            return
        }

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
    
    func find(at time: TimeInterval, in url: URL?) -> IndexSet {
        guard let storage, let url, url == self.url else { return [] }
        return storage.find(at: time)
    }
}
