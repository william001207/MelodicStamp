//
//  TTMLLyricLine.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder
import SFSafeSymbols

// MARK: - Lyric Line

struct TTMLLyricLine: LyricLine {
    let id = UUID()

    var index: Int
    var position: TTMLPosition

    var lyrics: TTMLLyrics = .init()
    var backgroundLyrics: TTMLLyrics = .init()
}

extension TTMLLyricLine {
    var beginTime: TimeInterval? {
        [lyrics, backgroundLyrics].compactMap(\.beginTime).min()
    }

    var endTime: TimeInterval? {
        [lyrics, backgroundLyrics].compactMap(\.endTime).max()
    }

    var condensedBeginTime: TimeInterval? {
        lyrics.beginTime
    }

    var condensedEndTime: TimeInterval? {
        lyrics.endTime
    }

    var content: String {
        lyrics.map(\.content).joined()
    }

    var backgroundContent: String {
        backgroundLyrics.map(\.content).joined()
    }

    var attachments: LyricsAttachments {
        var attachments: LyricsAttachments = []

        if ![lyrics, backgroundLyrics].flatMap(\.translations).isEmpty {
            attachments.formUnion(.translation)
        }

        if ![lyrics, backgroundLyrics].compactMap(\.roman).isEmpty {
            attachments.formUnion(.roman)
        }

        return attachments
    }
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

// MARK: - Vowel Time

struct TTMLVowelTime: Equatable, Hashable {
    var beginTime: TimeInterval
    var endTime: TimeInterval
}

extension TTMLVowelTime {
    var duration: TimeInterval { endTime - beginTime }
    
    func contains(time: TimeInterval) -> Bool {
        beginTime...endTime ~= time
    }
}

extension TTMLVowelTime: Comparable {
    static func < (lhs: TTMLVowelTime, rhs: TTMLVowelTime) -> Bool {
        lhs.beginTime < rhs.beginTime
    }
}

// MARK: - Translation

struct TTMLTranslation: Equatable, Hashable, Identifiable {
    var locale: TTMLLocale
    var text: String

    let id = UUID()
}

// MARK: - Lyric

struct TTMLLyric: Equatable, Hashable, Identifiable, AnimatedString {
    let id = UUID()

    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    var text: String
    var trailingSpaceCount: Int = 0

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

// MARK: - Lyrics

struct TTMLLyrics: Equatable, Hashable {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?

    var vowelTimes: Set<TTMLVowelTime> = []

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
        var result: Set<TTMLVowelTime> = []
        var latestVowelTime: TimeInterval?

        for (index, lyric) in enumerated() {
            guard let beginTime = lyric.beginTime, let endTime = lyric.endTime else { continue }
            let reachedEnd = index >= endIndex - 1

            if let unweappedLatestVowelTime = latestVowelTime {
                // Find an ending vowel

                if reachedEnd || lyric.startsWithVowel || !lyric.isVowel {
                    latestVowelTime = nil

                    if endTime - unweappedLatestVowelTime >= threshold {
                        // Reached threshold, count as a long vowel

                        result.insert(.init(beginTime: unweappedLatestVowelTime, endTime: endTime))
                    }
                }
            } else {
                // Find a starting vowel

                if lyric.endsWithVowel || lyric.isVowel {
                    latestVowelTime = beginTime

                    if reachedEnd, endTime - beginTime >= threshold {
                        // The last long vowel
                        result.insert(.init(beginTime: beginTime, endTime: endTime))
                    }
                }
            }
        }

        vowelTimes = result
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
