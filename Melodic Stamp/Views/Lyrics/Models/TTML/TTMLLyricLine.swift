//
//  TTMLLyricLine.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder
import SFSafeSymbols

struct TTMLLyricLine: LyricLine {
    var index: Int
    var position: TTMLPosition

    // Do not use sequences, otherwise causing huge performance issues
    var beginTime: TimeInterval? {
        if
            let lyricsBeginTime = lyrics.beginTime,
            let backgroundLyricsBeginTime = backgroundLyrics.beginTime {
            min(lyricsBeginTime, backgroundLyricsBeginTime)
        } else if let lyricsBeginTime = lyrics.beginTime {
            lyricsBeginTime
        } else if let backgroundLyricsBeginTime = backgroundLyrics.beginTime {
            backgroundLyricsBeginTime
        } else {
            nil
        }
    }

    var endTime: TimeInterval? {
        if
            let lyricsEndTime = lyrics.endTime,
            let backgroundLyricsEndTime = backgroundLyrics.endTime {
            max(lyricsEndTime, backgroundLyricsEndTime)
        } else if let lyricsEndTime = lyrics.endTime {
            lyricsEndTime
        } else if let backgroundLyricsEndTime = backgroundLyrics.endTime {
            backgroundLyricsEndTime
        } else {
            nil
        }
    }

    var lyrics: TTMLLyrics = .init()
    var backgroundLyrics: TTMLLyrics = .init()

    let id = UUID()
}

extension TTMLLyricLine: Equatable {
    static func == (lhs: TTMLLyricLine, rhs: TTMLLyricLine) -> Bool {
        lhs.id == rhs.id
    }
}

extension TTMLLyricLine: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Lyric

struct TTMLLyric: Equatable, Hashable, Identifiable, AnimatedString {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    var text: String
    var trailingSpaceCount: Int = 0

    let id = UUID()

    var content: String {
        text + .init(repeating: " ", count: trailingSpaceCount)
    }
}


// MARK: - Translation

typealias TTMLLocale = Locale

extension TTMLLocale {
    var main: String? {
        identifier.split(separator: /[-_]/).first.map(String.init)
    }

    var symbolLocalization: Localization? {
        main.flatMap(Localization.init(rawValue:))
    }

    func localize(systemSymbol symbol: SFSymbol) -> SFSymbol? {
        symbolLocalization.flatMap(symbol.localized(to:))
    }
}

struct TTMLTranslation: Equatable, Hashable, Identifiable {
    var locale: TTMLLocale
    var text: String

    let id = UUID()
}

// MARK: - Lyrics

struct TTMLLyrics: Equatable, Hashable {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?

    var children: [TTMLLyric] = []
    var translations: [TTMLTranslation] = []
    var roman: String?
}

extension TTMLLyrics: Sequence {
    func makeIterator() -> Array<TTMLLyric>.Iterator {
        children.makeIterator()
    }
}

extension TTMLLyrics: MutableCollection {
    var startIndex: Int { children.startIndex }
    var endIndex: Int { children.endIndex }
    var count: Int { children.count }

    func index(after i: Int) -> Int {
        children.index(after: i)
    }

    subscript(index: Int) -> TTMLLyric {
        get {
            children[index]
        }

        set {
            children[index] = newValue
        }
    }
}

extension TTMLLyrics: RangeReplaceableCollection {
    mutating func replaceSubrange(
        _ subrange: Range<Int>,
        with newElements: some Collection<TTMLLyric>
    ) {
        children.replaceSubrange(subrange, with: newElements)
    }
}

extension TTMLLyrics {
    mutating func insertSpaces(from template: String) {
        let terminator: Character = ";"
        var indexedTemplate = template
        enumerated().forEach {
            indexedTemplate.replace(
                $1.text,
                with: "\($0)\(terminator)",
                maxReplacements: 1
            )
        }

        let consecutiveSpaces = indexedTemplate
            .countConsecutiveSpacesBetweenNumbers(terminator: terminator)

        for (index, spaceCount) in consecutiveSpaces {
            guard indices.contains(index) else { continue }
            self[index].trailingSpaceCount = spaceCount
        }
    }
}

// MARK: - Position

enum TTMLPosition: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case main
    case sub

    var id: String { rawValue }
}
