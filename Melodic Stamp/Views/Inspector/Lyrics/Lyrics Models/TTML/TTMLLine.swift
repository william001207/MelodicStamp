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
    var beginTime: TimeInterval? { lyrics.beginTime }
    var endTime: TimeInterval? { lyrics.endTime }
    
    var lyrics: TTMLLyrics = .init()
    var backgroundLyrics: TTMLLyrics = .init()

    let id = UUID()
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
    
    var trailingSpaceCount: Int = 0
}

// MARK: - Lyrics

struct TTMLLyrics: Equatable, Hashable, Codable {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    
    var children: [TTMLLyric] = []
    var translation: String?
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
    mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == TTMLLyric {
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
