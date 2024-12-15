//
//  TTMLLine.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

struct TTMLLine: LyricLine {
    var index: Int
    var position: TTMLPosition
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    
    var lyrics: TTMLLyrics = .init()
    var backgroundLyrics: TTMLLyrics = .init()

    let id: UUID = .init()

    var content: String {
        lyrics.map(\.text).joined(separator: " ")
    }

    var isValid: Bool {
        beginTime != nil || endTime != nil
    }
}

extension TTMLLine: Equatable {
    static func == (lhs: TTMLLine, rhs: TTMLLine) -> Bool {
        lhs.id == rhs.id
    }
}

extension TTMLLine: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Lyric

struct TTMLLyric: Equatable, Hashable, Codable {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    var text: String
}

// MARK: - Lyrics

struct TTMLLyrics: Equatable, Hashable, Codable {
    var children: [TTMLLyric] = []
    var translation: String?
    var roman: String?
}

extension TTMLLyrics: Sequence {
    func makeIterator() -> Array<TTMLLyric>.Iterator {
        children.makeIterator()
    }
}

extension TTMLLyrics: Collection {
    var startIndex: Int { children.startIndex }
    var endIndex: Int { children.endIndex }
    var count: Int { children.count }
    
    func index(after i: Int) -> Int {
        children.index(after: i)
    }
    
    subscript(index: Int) -> TTMLLyric {
        children[index]
    }
}

extension TTMLLyrics: RangeReplaceableCollection {
    mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == TTMLLyric {
        children.replaceSubrange(subrange, with: newElements)
    }
}

// MARK: - Position

enum TTMLPosition: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case main
    case sub
    
    var id: String { rawValue }
}
