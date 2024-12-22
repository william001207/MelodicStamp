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
            let agent = try TTMLData(type: .agent, element: pElement)

            var line = TTMLLine(
                index: index,
                position: Self.getPosition(fromAgent: agent?.content)
            )

            try Self.readNodes(
                from: pElement,
                into: &line.lyrics,
                intoBackground: &line.backgroundLyrics,
                isRecursive: true
            )

            lines.append(line)
        }
    }

    func find(at time: TimeInterval) -> Range<Int> {
        var lowerBound: Int?, upperBound: Int?
        
        func insert(_ index: Int) {
            if lowerBound == nil {
                lowerBound = index
            }
            upperBound = index
        }

        for (index, line) in lines.enumerated() {
            if let beginTime = line.beginTime as TimeInterval?,
               let endTime = line.endTime as TimeInterval? {
                if time >= beginTime, time <= endTime {
                    insert(index)
                }
            }
        }

        guard let lowerBound, let upperBound else { return 0..<0 }
        return lowerBound..<upperBound
    }

    static func getPosition(fromAgent agent: String?) -> TTMLPosition {
        guard let agent else { return .main }
        return switch agent {
        case "v1": .main
        default: .sub
        }
    }

    static func readTimestamp(from element: Element, into lyrics: inout TTMLLyrics) throws {
        let beginTime = try TTMLData(type: .begin, element: element)?.content.toTTMLTimeInterval()
        let endTime = try TTMLData(type: .end, element: element)?.content.toTTMLTimeInterval()

        lyrics.beginTime = beginTime
        lyrics.endTime = endTime
    }

    static func readNodes(
        from element: Element,
        into lyrics: inout TTMLLyrics,
        intoBackground backgroundLyrics: inout TTMLLyrics,
        isRecursive: Bool = false
    ) throws {
        try readTimestamp(from: element, into: &lyrics)
        var text = try element.text()

        for node in element.getChildNodes() {
            if let textNode = node as? TextNode {
                let text = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }

                lyrics.append(.init(text: text))
            } else if
                let spanElement = node as? Element,
                spanElement.tagName() == "span" {
                let beginTime = try TTMLData(type: .begin, element: spanElement)?.content.toTTMLTimeInterval()
                let endTime = try TTMLData(type: .end, element: spanElement)?.content.toTTMLTimeInterval()
                let spanText = try spanElement
                    .text()
                    .normalizeSpaces()

                if let roleAttribute = try TTMLData(type: .role, element: spanElement)?.content,
                   let role = TTMLRole(rawValue: roleAttribute) {
                    switch role {
                    case .translation:
                        lyrics.translation = spanText
                    case .roman:
                        lyrics.roman = spanText
                    case .background:
                        if isRecursive {
                            var dummy: TTMLLyrics = .init()
                            try readNodes(
                                from: spanElement,
                                into: &backgroundLyrics,
                                intoBackground: &dummy,
                                isRecursive: false
                            )
                        }
                    }

                    text.replace(spanText, with: "", maxReplacements: 1)
                } else {
                    lyrics.append(.init(
                        beginTime: beginTime, endTime: endTime, text: spanText
                    ))
                }
            }
        }

        // Preservs spaces between span elements
        lyrics.insertSpaces(from: text)
    }
}
