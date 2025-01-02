//
//  TTMLParser.swift
//  MelodicStamp
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

    typealias Line = TTMLLyricLine

    var lines: [TTMLLyricLine] = []

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

            var line = TTMLLyricLine(
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

    static func getPosition(fromAgent agent: String?) -> TTMLPosition {
        guard let agent else { return .main }
        return switch agent {
        case "v1": .main
        default: .sub
        }
    }

    static func readTimestamp(from element: Element) throws -> (beginTime: TimeInterval?, endTime: TimeInterval?) {
        let beginTime = try TTMLData(type: .begin, element: element)?.content.toTTMLTimestamp()
        let endTime = try TTMLData(type: .end, element: element)?.content.toTTMLTimestamp()

        return (beginTime, endTime)
    }

    static func readNodes(
        from element: Element,
        into lyrics: inout TTMLLyrics,
        intoBackground backgroundLyrics: inout TTMLLyrics,
        isRecursive: Bool = false
    ) throws {
        let (beginTime, endTime) = try readTimestamp(from: element)
        lyrics.beginTime = beginTime
        lyrics.endTime = endTime

        var text = try element.text()

        for node in element.getChildNodes() {
            if let textNode = node as? TextNode {
                let text = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }

                lyrics.append(.init(
                    beginTime: beginTime, endTime: endTime,
                    text: text.removingParentheses
                ))
            } else if
                let spanElement = node as? Element,
                spanElement.tagName() == "span" {
                let (beginTime, endTime) = try readTimestamp(from: spanElement)
                let spanText = try spanElement
                    .text()
                    .normalizingSpaces

                if
                    let roleData = try TTMLData(type: .role, element: spanElement),
                    let role = TTMLRole(rawValue: roleData.content) {
                    switch role {
                    case .translation:
                        guard let language = try TTMLData(type: .language, element: spanElement) else { break }

                        let locale = Locale(identifier: language.content)
                        lyrics.translations.append(.init(
                            locale: locale,
                            text: spanText.removingParentheses
                        ))
                    case .roman:
                        lyrics.roman = spanText
                    case .background:
                        guard isRecursive else { break }
                        var dummy: TTMLLyrics = .init()
                        try readNodes(
                            from: spanElement,
                            into: &backgroundLyrics,
                            intoBackground: &dummy,
                            isRecursive: false
                        )
                    }

                    text.replace(spanText, with: "", maxReplacements: 1)
                } else {
                    lyrics.append(.init(
                        beginTime: beginTime, endTime: endTime,
                        text: spanText.removingParentheses
                    ))
                }
            }
        }

        // Preservs spaces between span elements
        lyrics.insertSpaces(template: text)

        // Finds vowels
        lyrics.findVowels()
    }
}
