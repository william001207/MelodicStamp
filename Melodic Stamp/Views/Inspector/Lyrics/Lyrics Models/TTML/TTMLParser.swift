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
    typealias Tag = TTMLTag
    typealias Line = TTMLLine

    var lines: [TTMLLine] = []

    required init(string: String) throws {
        try parseLyrics(from: string)
    }

    private func parseLyrics(from string: String) throws {
        guard let doc = try? SwiftSoup.parse(string) else {
            throw NSError(domain: "ParseError", code: -1, userInfo: nil)
        }
        guard let body = doc.body() else {
            throw NSError(domain: "BodyError", code: -1, userInfo: nil)
        }

        let pElements = try body.getElementsByTag("p")
        for (index, pElement) in pElements.enumerated() {
            let beginTimeStr = try pElement.attr("begin")
            let endTimeStr = try pElement.attr("end")
            let ttmAgent = try pElement.attr("ttm:agent")

            let beginTime = beginTimeStr.toTimeInterval()
            let endTime = endTimeStr.toTimeInterval()

            var lyricLine = TTMLLine(
                index: index,
                position: getPositionFromAgent(ttmAgent),
                beginTime: beginTime,
                endTime: endTime,
                mainLyric: [],
                bgLyric: nil,
                translation: nil,
                roman: nil
            )

            var tags: [TTMLTag] = []

            let possibleAttributes = [
                "begin", "end", "ttm:agent", "itunes:key", "ttm:translation",
                "ttm:roman"
            ]

            for attribute in possibleAttributes {
                if pElement.hasAttr(attribute) {
                    let value = try pElement.attr(attribute)
                    if let tagType = TTMLTag.TagType(
                        rawValue: attribute) {
                        let tag = TTMLTag(type: tagType, content: value)
                        tags.append(tag)
                    }
                }
            }

            lyricLine.tags = tags

            let childNodes = pElement.getChildNodes()
            for node in childNodes {
                if let textNode = node as? TextNode {
                    let text = textNode.text().trimmingCharacters(
                        in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        let subLyric = TTMLSubLyric(
                            beginTime: beginTime, endTime: endTime, text: text
                        )
                        lyricLine.mainLyric?.append(subLyric)
                    }
                } else if let spanElement = node as? Element,
                          spanElement.tagName() == "span" {
                    let role = try spanElement.attr("ttm:role")
                    let text = try spanElement.getPreservedText()
                        .normalizeSpaces()

                    switch role {
                    case "x-translation":
                        lyricLine.translation = text
                        if let tagType = TTMLTag.TagType(
                            rawValue: "ttm:translation") {
                            let tag = TTMLTag(type: tagType, content: text)
                            lyricLine.tags.append(tag)
                        }
                    case "x-roman":
                        lyricLine.roman = text
                        if let tagType = TTMLTag.TagType(
                            rawValue: "ttm:roman") {
                            let tag = TTMLTag(type: tagType, content: text)
                            lyricLine.tags.append(tag)
                        }
                    case "x-bg":
                        var bgLyric = TTMLBackgroundLyric(
                            subLyric: [], translation: nil, roman: nil
                        )
                        let bgSpanElements = try spanElement.getElementsByTag(
                            "span")
                        var bgSubTtmlLyricList: [TTMLSubLyric] = []

                        for bgSpanElement in bgSpanElements {
                            let bgBeginTime = try bgSpanElement.attr("begin")
                                .toTimeInterval()
                            let bgEndTime = try bgSpanElement.attr("end")
                                .toTimeInterval()
                            let bgText = try bgSpanElement.getPreservedText()
                                .normalizeSpaces().replacingOccurrences(
                                    of: "[()]", with: "",
                                    options: .regularExpression
                                )

                            let bgSubLyric = TTMLSubLyric(
                                beginTime: bgBeginTime,
                                endTime: bgEndTime,
                                text: bgText
                            )
                            bgSubTtmlLyricList.append(bgSubLyric)
                        }

                        bgLyric.children =
                            bgSubTtmlLyricList.isEmpty
                                ? nil : bgSubTtmlLyricList
                        lyricLine.bgLyric = bgLyric
                    default:
                        break
                    }
                }
            }

            lines.append(lyricLine)
        }

        if lines.isEmpty {
            throw NSError(domain: "EmptyLyrics", code: -1, userInfo: nil)
        }
    }
    
    func find(at time: TimeInterval) -> IndexSet {
        var indices = IndexSet()
        for (index, line) in lines.enumerated() {
            if let startTime = line.startTime as TimeInterval?,
               let endTime = line.endTime as TimeInterval? {
                if time >= startTime, time <= endTime {
                    indices.insert(index)
                }
            }
        }
        return indices
    }

    static func parseTag(string: String) throws -> TTMLTag? {
        let regex = Regex {
            Capture {
                Tag.TagType.regex
            }
            "="
            Capture {
                OneOrMore {
                    CharacterClass(.anyNonNewline)
                }
            }
        }

        guard let match = try regex.wholeMatch(in: string) else { return nil }
        let key = String(match.output.1)
        let value = String(match.output.2)

        guard let type = Tag.TagType(rawValue: key) else {
            return nil
        }
        return TTMLTag(type: type, content: value)
    }
    
    static func getPositionFromAgent(_ agent: String) -> TTMLPosition {
        switch agent {
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

// MARK: - Tets TTML Parser

struct TestTtmlLyric: Identifiable, Equatable {
    var id = UUID()
    var indexNum: Int
    var position: TestTtmlLyricPositionType
    var beginTime: TimeInterval
    var endTime: TimeInterval

    var mainLyric: [TestSubTtmlLyric]?
    var bgLyric: TestBgTtmlLyric?
    var translation: String?
    var roman: String?

    static func == (lhs: TestTtmlLyric, rhs: TestTtmlLyric) -> Bool {
        lhs.id == rhs.id
    }
}

struct TestSubTtmlLyric {
    var beginTime: TimeInterval
    var endTime: TimeInterval
    var text: String
}

struct TestBgTtmlLyric {
    var subLyrics: [TestSubTtmlLyric]?
    var translation: String?
    var roman: String?
}

enum TestTtmlLyricPositionType {
    case main
    case sub
}

class TestTTMLParser: NSObject {
    private var currentIndexNum: Int = 0
    private var ttmlLyrics: [TestTtmlLyric] = []
    private var currentTtmlLyric: TestTtmlLyric?
    private var currentSubTtmlLyrics: [TestSubTtmlLyric] = []
    private var currentTranslation: String?
    private var currentRoman: String?
    private var currentBgLyric: TestBgTtmlLyric?
    private var currentElement: String?
}

extension TestTTMLParser {
    func decodeTtml(data: Data, coderType: String.Encoding) async throws
        -> [TestTtmlLyric] {
        guard let htmlString = String(data: data, encoding: coderType) else {
            throw NSError()
        }
        return try await decodeTtml(htmlString: htmlString)
    }
}

extension TestTTMLParser {
    func decodeTtml(htmlString: String) async throws -> [TestTtmlLyric] {
        guard let doc = try? SwiftSoup.parse(htmlString) else {
            throw NSError()
        }
        guard let body = doc.body() else { throw NSError() }

        var ttmlLyrics: [TestTtmlLyric] = []

        do {
            let pElements = try body.getElementsByTag("p")
            for (index, pElement) in pElements.enumerated() {
                let beginTime = try pElement.attr("begin")
                let endTime = try pElement.attr("end")
                let ttmAgent = try pElement.attr("ttm:agent")
                let itunesKey = try pElement.attr("itunes:key")

                if !ttmAgent.isEmpty || !itunesKey.isEmpty {
                    var currentTtmlLyric = TestTtmlLyric(
                        indexNum: index,
                        position: getPositionFromAgent(ttmAgent),
                        beginTime: beginTime.toTimeInterval(),
                        endTime: endTime.toTimeInterval(),
                        mainLyric: [],
                        bgLyric: nil,
                        translation: nil,
                        roman: nil
                    )

                    var currentSubTtmlLyrics: [TestSubTtmlLyric] = []
                    var currentTranslation: String?
                    var currentRoman: String?
                    var currentBgLyric: TestBgTtmlLyric?
                    var bgSubTtmlLyricList: [TestSubTtmlLyric] = []

                    let childNodes = try pElement.getChildNodes()
                    for node in childNodes {
                        if let textNode = node as? TextNode {
                            let text = textNode.text()
                            if let lastLyric = currentSubTtmlLyrics.last {
                                currentSubTtmlLyrics[
                                    currentSubTtmlLyrics.count - 1
                                ].text += text
                            } else {
                                let spaceLyric = TestSubTtmlLyric(
                                    beginTime: 0, endTime: 0, text: text
                                )
                                currentSubTtmlLyrics.append(spaceLyric)
                            }
                        } else if let spanElement = node as? Element,
                                  spanElement.tagName() == "span" {
                            let role = try spanElement.attr("ttm:role")
                            var text: String

                            if role == "x-translation" {
                                text = try spanElement.getPreservedText()
                                    .normalizeSpaces()
                                currentTranslation = text
                            } else if role == "x-roman" {
                                text = try spanElement.getPreservedText()
                                    .normalizeSpaces()
                                currentRoman = text
                            } else if role == "x-bg" {
                                // 处理背景歌词
                                if currentBgLyric == nil {
                                    currentBgLyric = TestBgTtmlLyric(
                                        subLyrics: [], translation: nil,
                                        roman: nil
                                    )
                                }

                                let bgSpanElements = spanElement.children()
                                for bgSpanElement in bgSpanElements {
                                    let bgRole = try bgSpanElement.attr(
                                        "ttm:role")
                                    var bgSpanText =
                                        try bgSpanElement.getPreservedText()
                                    bgSpanText =
                                        bgSpanText.replacingOccurrences(
                                            of: "[()]", with: "",
                                            options: .regularExpression
                                        )

                                    if bgRole == "x-translation" {
                                        currentBgLyric?.translation = bgSpanText
                                    } else if bgRole == "x-roman" {
                                        currentBgLyric?.roman = bgSpanText
                                    } else if bgSpanElement.hasAttr("begin") {
                                        let bgBeginTime =
                                            try bgSpanElement.attr("begin")
                                                .toTimeInterval()
                                        let bgEndTime = try bgSpanElement.attr(
                                            "end"
                                        ).toTimeInterval()
                                        let bgSubTtmlLyric = TestSubTtmlLyric(
                                            beginTime: bgBeginTime,
                                            endTime: bgEndTime,
                                            text: bgSpanText.normalizeSpaces()
                                        )
                                        bgSubTtmlLyricList.append(
                                            bgSubTtmlLyric)
                                    }
                                }
                                currentBgLyric?.subLyrics =
                                    bgSubTtmlLyricList.isEmpty
                                        ? nil : bgSubTtmlLyricList
                                // 跳过x-bg标签的子内容，避免重复处理
                                continue
                            } else {
                                // 处理主歌词的子歌词
                                let subLyricBeginTime = try spanElement.attr(
                                    "begin")
                                let subLyricEndTime = try spanElement.attr(
                                    "end")
                                let subTtmlLyric = try TestSubTtmlLyric(
                                    beginTime:
                                    subLyricBeginTime.toTimeInterval(),
                                    endTime: subLyricEndTime.toTimeInterval(),
                                    text: spanElement.getPreservedText()
                                        .normalizeSpaces()
                                )
                                currentSubTtmlLyrics.append(subTtmlLyric)
                            }
                        }
                    }

                    currentTtmlLyric.mainLyric = currentSubTtmlLyrics
                    currentTtmlLyric.bgLyric = currentBgLyric
                    currentTtmlLyric.translation = currentTranslation
                    currentTtmlLyric.roman = currentRoman

                    // 避免翻译重复，如果 bgLyric.translation 和 mainLyric.translation 相同，则将 mainLyric.translation 设为 nil
                    if let bgTranslation = currentTtmlLyric.bgLyric?
                        .translation,
                        let mainTranslation = currentTtmlLyric.translation,
                        bgTranslation == mainTranslation {
                        currentTtmlLyric.translation = nil
                    }

                    ttmlLyrics.append(currentTtmlLyric)
                }
            }
        } catch {
            throw error
        }

        if ttmlLyrics.isEmpty { throw NSError() }
        return ttmlLyrics
    }
}

extension TestTTMLParser {
    private func getPositionFromAgent(_ agent: String)
        -> TestTtmlLyricPositionType {
        if agent == "v1" { return .main }
        return .sub
    }
}

func loadGBKFile(fileURL: URL) -> String? {
    do {
        let data = try Data(contentsOf: fileURL)
        if let gbkString = String(data: data, encoding: .gbk) {
            return gbkString
        }
    } catch {
        print("Error loading file: \(error)")
    }

    return nil
}
