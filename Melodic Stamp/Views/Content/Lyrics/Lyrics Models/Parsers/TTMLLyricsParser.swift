//
//  TTMLLyricsParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import SwiftSoup
import RegexBuilder

public struct TTMLLyricTag: Hashable, Identifiable, Equatable {
    public enum LyricTagType: String, Hashable, Identifiable, Equatable, CaseIterable {
        case begin
        case end
        case agent = "ttm:agent"
        case itunesKey = "itunes:key"
        case translation = "ttm:translation"
        case roman = "ttm:roman"
        
        public var id: String {
            rawValue
        }
        
        public var name: String {
            switch self {
            case .begin:
                return NSLocalizedString("Begin", comment: "")
            case .end:
                return NSLocalizedString("End", comment: "")
            case .agent:
                return NSLocalizedString("Agent", comment: "")
            case .itunesKey:
                return NSLocalizedString("iTunes Key", comment: "")
            case .translation:
                return NSLocalizedString("Translation", comment: "")
            case .roman:
                return NSLocalizedString("Roman", comment: "")
            }
        }
        
        public static var regex: Regex<Substring> {
            Regex {
                ChoiceOf {
                    "begin"
                    "end"
                    "ttm:agent"
                    "itunes:key"
                    "ttm:translation"
                    "ttm:roman"
                }
            }
        }
    }
    
    public var id: LyricTagType {
        type
    }
    
    public var type: LyricTagType
    public var content: String
    
    public init(type: LyricTagType, content: String) {
        self.type = type
        self.content = content
    }
}

struct TTMLLyricLine: LyricLine {
    
    typealias Tag = TTMLLyricTag
    
    var id = UUID()
    var indexNum: Int
    var position: TtmlLyricPositionType
    var beginTime: TimeInterval
    var endTime: TimeInterval?
    var tags: [TTMLLyricTag] = []
    var mainLyric: [SubTtmlLyric]?
    var bgLyric: BgTtmlLyric?
    var translation: String?
    var roman: String?
    
    var startTime: TimeInterval? {
        get { beginTime }
        set { if let newValue = newValue { beginTime = newValue } }
    }
    
    var content: String {
        get {
            mainLyric?.map { $0.text }.joined(separator: " ") ?? ""
        }
        set {
        }
    }

    var isValid: Bool {
        return startTime != nil || endTime != nil
    }

    // Implementing Equatable and Hashable
    static func == (lhs: TTMLLyricLine, rhs: TTMLLyricLine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct SubTtmlLyric {
    public var beginTime: TimeInterval
    public var endTime: TimeInterval
    public var text: String
    
    public init(beginTime: TimeInterval, endTime: TimeInterval, text: String) {
        self.beginTime = beginTime
        self.endTime = endTime
        self.text = text
    }
}

public struct BgTtmlLyric {
    public var subLyric: [SubTtmlLyric]?
    public var translation: String?
    public var roman: String?
    
    public init(subLyric: [SubTtmlLyric]? = nil, translation: String? = nil, roman: String? = nil) {
        self.subLyric = subLyric
        self.translation = translation
        self.roman = roman
    }
}

public enum TtmlLyricPositionType {
    case main
    case sub
}

@Observable
public class TTMLLyricsParser: NSObject, LyricsParser {
    typealias Tag = TTMLLyricTag
    typealias Line = TTMLLyricLine
    
    var lines: [TTMLLyricLine] = []
    
    required init(string: String) throws {
        super.init()
        try self.parseLyrics(from: string)
    }
    
    required override init() {
        super.init()
    }
    
    func find(at time: TimeInterval) -> IndexSet {
        var indices = IndexSet()
        for (index, line) in lines.enumerated() {
            if let startTime = line.beginTime as TimeInterval?,
               let endTime = line.endTime as TimeInterval? {
                if time >= startTime && time <= endTime {
                    indices.insert(index)
                }
            }
        }
        return indices
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

            var lyricLine = TTMLLyricLine(
                indexNum: index,
                position: getPositionFromAgent(ttmAgent),
                beginTime: beginTime,
                endTime: endTime,
                mainLyric: [],
                bgLyric: nil,
                translation: nil,
                roman: nil
            )

            var tags: [TTMLLyricTag] = []

            let possibleAttributes = ["begin", "end", "ttm:agent", "itunes:key", "ttm:translation", "ttm:roman"]

            for attribute in possibleAttributes {
                if pElement.hasAttr(attribute) {
                    let value = try pElement.attr(attribute)
                    if let tagType = TTMLLyricTag.LyricTagType(rawValue: attribute) {
                        let tag = TTMLLyricTag(type: tagType, content: value)
                        tags.append(tag)
                    }
                }
            }

            lyricLine.tags = tags

            let childNodes = pElement.getChildNodes()
            for node in childNodes {
                if let textNode = node as? TextNode {
                    let text = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        let subLyric = SubTtmlLyric(beginTime: beginTime, endTime: endTime, text: text)
                        lyricLine.mainLyric?.append(subLyric)
                    }
                } else if let spanElement = node as? Element, spanElement.tagName() == "span" {
                    let role = try spanElement.attr("ttm:role")
                    let text = try spanElement.getPreservedText().normalizeSpaces()

                    switch role {
                    case "x-translation":
                        lyricLine.translation = text
                        if let tagType = TTMLLyricTag.LyricTagType(rawValue: "ttm:translation") {
                            let tag = TTMLLyricTag(type: tagType, content: text)
                            lyricLine.tags.append(tag)
                        }
                    case "x-roman":
                        lyricLine.roman = text
                        if let tagType = TTMLLyricTag.LyricTagType(rawValue: "ttm:roman") {
                            let tag = TTMLLyricTag(type: tagType, content: text)
                            lyricLine.tags.append(tag)
                        }
                    case "x-bg":
                        var bgLyric = BgTtmlLyric(subLyric: [], translation: nil, roman: nil)
                        let bgSpanElements = try spanElement.getElementsByTag("span")
                        var bgSubTtmlLyricList: [SubTtmlLyric] = []

                        for bgSpanElement in bgSpanElements {
                            let bgBeginTime = try bgSpanElement.attr("begin").toTimeInterval()
                            let bgEndTime = try bgSpanElement.attr("end").toTimeInterval()
                            let bgText = try bgSpanElement.getPreservedText().normalizeSpaces().replacingOccurrences(of: "[()]", with: "", options: .regularExpression)

                            let bgSubLyric = SubTtmlLyric(
                                beginTime: bgBeginTime,
                                endTime: bgEndTime,
                                text: bgText
                            )
                            bgSubTtmlLyricList.append(bgSubLyric)
                        }

                        bgLyric.subLyric = bgSubTtmlLyricList.isEmpty ? nil : bgSubTtmlLyricList
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
    
    private func getPositionFromAgent(_ agent: String) -> TtmlLyricPositionType {
        if agent == "v1" { return .main }
        return .sub
    }
    
    public static func parseTag(string: String) throws -> TTMLLyricTag? {
        let regex = Regex {
            Capture {
                Tag.LyricTagType.regex
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
        
        guard let type = Tag.LyricTagType(rawValue: key) else {
            return nil
        }
        return TTMLLyricTag(type: type, content: value)
    }
}

extension Element {
    func getPreservedText() throws -> String {
        var result = ""
        for node in self.getChildNodes() {
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
