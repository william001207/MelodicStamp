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

            for node in pElement.getChildNodes() {
                if let textNode = node as? TextNode {
                    let text = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { continue }
                    
                    line.lyrics.append(TTMLLyric(
                        beginTime: beginTime, endTime: endTime, text: text
                    ))
                } else if
                    let spanElement = node as? Element,
                        spanElement.tagName() == "span",
                    let role = try TTMLData(type: .role, element: spanElement),
                    let roleAttribute = TTMLRole(rawValue: role.content)
                {
                    let text = try spanElement.getPreservedText()
                        .normalizeSpaces()

                    switch roleAttribute {
                    case .translation:
                        line.lyrics.translation = text
                    case .roman:
                        line.lyrics.roman = text
                    case .background:
                        
                    }
                    
//                    case "x-bg":
//                        var bgLyric = TTMLBackgroundLyric(
//                            subLyric: [], translation: nil, roman: nil
//                        )
//                        let bgSpanElements = try spanElement.getElementsByTag(
//                            "span")
//                        var bgSubTtmlLyricList: [TTMLSubLyric] = []
//
//                        for bgSpanElement in bgSpanElements {
//                            let bgBeginTime = try bgSpanElement.attr("begin")
//                                .toTimeInterval()
//                            let bgEndTime = try bgSpanElement.attr("end")
//                                .toTimeInterval()
//                            let bgText = try bgSpanElement.getPreservedText()
//                                .normalizeSpaces().replacingOccurrences(
//                                    of: "[()]", with: "",
//                                    options: .regularExpression
//                                )
//
//                            let bgSubLyric = TTMLSubLyric(
//                                beginTime: bgBeginTime,
//                                endTime: bgEndTime,
//                                text: bgText
//                            )
//                            bgSubTtmlLyricList.append(bgSubLyric)
//                        }
//
//                        bgLyric.children =
//                            bgSubTtmlLyricList.isEmpty
//                                ? nil : bgSubTtmlLyricList
//                        lyricLine.bgLyric = bgLyric
                }
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
