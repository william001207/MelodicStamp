//
//  TTMLLyricLine.swift
//  MelodicStamp
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

    var content: String {
        lyrics.map(\.content).joined()
    }

    var backgroundContent: String {
        backgroundLyrics.map(\.content).joined()
    }

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

extension TTMLLyric {
    var startsWithVowel: Bool {
        String.vowels.contains {
            content.removingPunctuations
                .starts(with: $0)
        } && !isVowel
    }

    var endsWithVowel: Bool {
        String.vowels.contains {
            content.removingPunctuations
                .reversed
                .starts(with: $0)
        } && !isVowel
    }

    var isVowel: Bool {
        String.vowels.contains {
            content.removingPunctuations
                .wholeMatch(of: $0) != nil
        }
    }

    var isNonVowel: Bool {
        !(isVowel || startsWithVowel || endsWithVowel)
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

    var vowels: Set<TimeInterval> = []

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
    mutating func findVowels() {
        let threshold: TimeInterval = 1
        var result: Set<TimeInterval> = []
        var latestVowel: TimeInterval?

        for (index, lyric) in enumerated() {
            guard let beginTime = lyric.beginTime, let endTime = lyric.endTime else { continue }
            let reachedEnd = index >= endIndex - 1

            if let unweappedLatestVowel = latestVowel {
                // Find an ending vowel

                if reachedEnd || lyric.startsWithVowel || !lyric.isVowel {
                    latestVowel = nil

                    if endTime - unweappedLatestVowel >= threshold {
                        // Reached threshold, count as a long vowel

                        result.insert(unweappedLatestVowel)
                    }
                }
            } else {
                // Find a starting vowel

                if lyric.endsWithVowel || lyric.isVowel {
                    latestVowel = beginTime

                    if endTime - beginTime >= threshold {
                        // Must be a long vowel, insert in advance
                        result.insert(beginTime)
                    }
                }
            }
        }

        vowels = result
    }

    mutating func insertSpaces(template: String) {
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
