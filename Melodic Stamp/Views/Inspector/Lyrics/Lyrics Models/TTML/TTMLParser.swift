//
//  TTMLParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder
import SwiftSoup

@Observable final class TTMLParser: LyricsParser {
    enum ParseError: Error {
        case documentNotFound
        case bodyNotFound
    }
    
    typealias Line = TTMLLine

    var lines: [TTMLLine] = []

    required init(string: String) throws {
        try parseLyrics(string: string)
    }

    private func parseLyrics(string: String) throws {
        guard let document = try? SwiftSoup.parse(string) else {
            throw ParseError.documentNotFound
        }
        guard let body = document.body() else {
            throw ParseError.bodyNotFound
        }

        for (index, pElement) in try body.getElementsByTag("p").enumerated() {
            let beginTime = try TTMLData(type: .begin, element: pElement)?.content.toTimeInterval()
            let endTime = try  TTMLData(type: .end, element: pElement)?.content.toTimeInterval()
            let agent = try  TTMLData(type: .agent, element: pElement)

            var line = TTMLLine(
                index: index,
                position: Self.getPosition(fromAgent: agent?.content),
                beginTime: beginTime,
                endTime: endTime
            )

            var backgroundLyrics: TTMLLyrics? = .init()
            try Self.readNodes(from: pElement.getChildNodes(), into: &line.lyrics, recursive: &backgroundLyrics)
            
            if let backgroundLyrics {
                line.backgroundLyrics = backgroundLyrics
            }
            
            lines.append(line)
        }
    }
    
    func find(at time: TimeInterval) -> IndexSet {
        var indices = IndexSet()
        for (index, line) in lines.enumerated() {
            if let beginTime = line.beginTime as TimeInterval?,
               let endTime = line.endTime as TimeInterval? {
                if time >= beginTime, time <= endTime {
                    indices.insert(index)
                }
            }
        }
        return indices
    }
    
    static func getPosition(fromAgent agent: String?) -> TTMLPosition {
        guard let agent else { return .main }
        return switch agent {
        case "v1": .main
        default: .sub
        }
    }
    
    static func readNodes(from nodes: [Node], into lyrics: inout TTMLLyrics, recursive: inout TTMLLyrics?) throws {
        for node in nodes {
            if let textNode = node as? TextNode {
                let text = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }
                
                lyrics.append(.init(text: text))
            } else if
                let spanElement = node as? Element,
                spanElement.tagName() == "span"
            {
                let beginTime = try TTMLData(type: .begin, element: spanElement)?.content.toTimeInterval()
                let endTime = try TTMLData(type: .end, element: spanElement)?.content.toTimeInterval()
                let text = try spanElement
                    .getPreservedText()
                    .normalizeSpaces()
                
                lyrics.append(.init(
                    beginTime: beginTime, endTime: endTime, text: text
                ))
                
                if let roleAttribute = try TTMLData(type: .role, element: spanElement)?.content,
                   let role = TTMLRole(rawValue: roleAttribute) {
                    switch role {
                    case .translation:
                        lyrics.translation = text
                    case .roman:
                        lyrics.roman = text
                    case .background:
                        if var recursive {
                            var dummy: TTMLLyrics? = nil
                            try readNodes(from: spanElement.getChildNodes(), into: &recursive, recursive: &dummy)
                        }
                    }
                }
            }
        }
    }
}

extension Element {
    func getPreservedText() throws -> String {
        var result = ""
        for node in getChildNodes() {
            if let textNode = node as? TextNode {
                result += textNode.text()
                if textNode.text().hasSuffix(" ") {
                    result += " "
                }
            } else if let element = node as? Element {
                result += try element.getPreservedText()
            }
        }
        return result
    }
}
