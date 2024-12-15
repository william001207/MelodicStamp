//
//  TTMLLine.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

struct TTMLLine: LyricLine {
    typealias Tag = TTMLTag

    var index: Int
    var position: TTMLPosition
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    var tags: [TTMLTag] = []
    
    var lyrics: TTMLLyrics
    var backgroundLyrics: TTMLLyrics

    let id: UUID = .init()

    var content: String {
        lyrics.map(\.text).joined(separator: " ")
    }

    var isValid: Bool {
        startTime != nil || endTime != nil
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
    var startTime: TimeInterval
    var endTime: TimeInterval
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

// MARK: - Position

enum TTMLPosition: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case main
    case sub
    
    var id: String { rawValue }
}
