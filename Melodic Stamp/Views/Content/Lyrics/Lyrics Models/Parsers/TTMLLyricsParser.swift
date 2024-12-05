//
//  TTMLLyricsParser.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder
import SwiftSoup

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
                NSLocalizedString("Begin", comment: "")
            case .end:
                NSLocalizedString("End", comment: "")
            case .agent:
                NSLocalizedString("Agent", comment: "")
            case .itunesKey:
                NSLocalizedString("iTunes Key", comment: "")
            case .translation:
                NSLocalizedString("Translation", comment: "")
            case .roman:
                NSLocalizedString("Roman", comment: "")
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

    var indexNum: Int
    var position: TtmlLyricPositionType
    var beginTime: TimeInterval
    var endTime: TimeInterval?
    var tags: [TTMLLyricTag] = []
    var mainLyric: [TTMLSubLyric]?
    var bgLyric: TTMLBgLyric?
    var translation: String?
    var roman: String?

    let id: UUID = .init()

    var startTime: TimeInterval? {
        get { beginTime }
        set { if let newValue { beginTime = newValue } }
    }

    var content: String {
        get {
            mainLyric?.map(\.text).joined(separator: " ") ?? ""
        }
        set {}
    }

    var isValid: Bool {
        startTime != nil || endTime != nil
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

public struct TTMLSubLyric {
    public var beginTime: TimeInterval
    public var endTime: TimeInterval
    public var text: String

    public init(beginTime: TimeInterval, endTime: TimeInterval, text: String) {
        self.beginTime = beginTime
        self.endTime = endTime
        self.text = text
    }
}

public struct TTMLBgLyric {
    public var subLyric: [TTMLSubLyric]?
    public var translation: String?
    public var roman: String?

    public init(subLyric: [TTMLSubLyric]? = nil, translation: String? = nil, roman: String? = nil) {
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
        try parseLyrics(from: string)
    }

    override required init() {
        super.init()
    }

    func find(at time: TimeInterval) -> IndexSet {
        var indices = IndexSet()
        for (index, line) in lines.enumerated() {
            if let startTime = line.beginTime as TimeInterval?,
               let endTime = line.endTime as TimeInterval? {
                if time >= startTime, time <= endTime {
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
                        let subLyric = TTMLSubLyric(beginTime: beginTime, endTime: endTime, text: text)
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
                        var bgLyric = TTMLBgLyric(subLyric: [], translation: nil, roman: nil)
                        let bgSpanElements = try spanElement.getElementsByTag("span")
                        var bgSubTtmlLyricList: [TTMLSubLyric] = []

                        for bgSpanElement in bgSpanElements {
                            let bgBeginTime = try bgSpanElement.attr("begin").toTimeInterval()
                            let bgEndTime = try bgSpanElement.attr("end").toTimeInterval()
                            let bgText = try bgSpanElement.getPreservedText().normalizeSpaces().replacingOccurrences(of: "[()]", with: "", options: .regularExpression)

                            let bgSubLyric = TTMLSubLyric(
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

/*
 import Foundation
 import SwiftSoup

 public struct TtmlLyric : Identifiable, Equatable {
     public var id = UUID()
     public var indexNum     : Int
     public var position     : TtmlLyricPositionType
     public var beginTime    : TimeInterval
     public var endTime      : TimeInterval

     public var mainLyric    : [SubTtmlLyric]?
     public var bgLyric      : BgTtmlLyric?
     public var translation  : String?
     public var roman        : String?

     public static func == (lhs: TtmlLyric, rhs: TtmlLyric) -> Bool {
         lhs.id == rhs.id
     }
 }

 public struct SubTtmlLyric {
     public var beginTime : TimeInterval
     public var endTime   : TimeInterval
     public var text      : String
 }

 public struct BgTtmlLyric {
     public var subLyric     : [SubTtmlLyric]?
     public var translation  : String?
     public var roman        : String?
 }

 public enum TtmlLyricPositionType {
     case main
     case sub
 }

 public class TTMLParser: NSObject {
     private var currentIndexNum: Int = 0
     private var ttmlLyrics: [TtmlLyric] = []
     private var currentTtmlLyric: TtmlLyric?
     private var currentSubTtmlLyrics: [SubTtmlLyric] = []
     private var currentTranslation: String?
     private var currentRoman: String?
     private var currentBgLyric: BgTtmlLyric?
     private var currentElement: String?
 }

 extension TTMLParser {
     public func decodeTtml(data: Data, coderType: String.Encoding) async throws -> [TtmlLyric] {
         guard let htmlString = String(data: data, encoding: coderType) else { throw NSError() }
         return try await decodeTtml(htmlString: htmlString)
     }

     public func decodeTtml(htmlString: String) async throws -> [TtmlLyric] {
         guard let doc = try? SwiftSoup.parse(htmlString) else { throw NSError() }
         guard let body = doc.body() else { throw NSError() }

         var ttmlLyrics: [TtmlLyric] = []

         do {
             let pElements = try body.getElementsByTag("p")
             for (index, pElement) in pElements.enumerated() {
                 let beginTime = try pElement.attr("begin")
                 let endTime = try pElement.attr("end")
                 let ttmAgent = try pElement.attr("ttm:agent")
                 let itunesKey = try pElement.attr("itunes:key")

                 if !ttmAgent.isEmpty || !itunesKey.isEmpty {
                     var currentTtmlLyric = TtmlLyric(
                         indexNum: index,
                         position: getPositionFromAgent(ttmAgent),
                         beginTime: beginTime.toTimeInterval(),
                         endTime: endTime.toTimeInterval(),
                         mainLyric: [],
                         bgLyric: nil,
                         translation: nil,
                         roman: nil
                     )

                     var currentSubTtmlLyrics: [SubTtmlLyric] = []
                     var currentTranslation: String?
                     var currentRoman: String?
                     var currentBgLyric: BgTtmlLyric?
                     var bgSubLyricsElements: [Element] = []
                     var bgSubTtmlLyricList: [SubTtmlLyric] = []

                     let childNodes = try pElement.getChildNodes()
                     for node in childNodes {
                         if let textNode = node as? TextNode {
                             let text = textNode.text()
                             if let lastLyric = currentSubTtmlLyrics.last {
                                 currentSubTtmlLyrics[currentSubTtmlLyrics.count - 1].text += text
                             } else {
                                 let spaceLyric = SubTtmlLyric(beginTime: 0, endTime: 0, text: text)
                                 currentSubTtmlLyrics.append(spaceLyric)
                             }
                         } else if let spanElement = node as? Element, spanElement.tagName() == "span" {
                             let role = try spanElement.attr("ttm:role")
                             var text: String

                             if role == "x-translation" {
                                 text = try spanElement.getPreservedText().normalizeSpaces()
                                 currentTranslation = text
                             } else if role == "x-roman" {
                                 text = try spanElement.getPreservedText().normalizeSpaces()
                                 currentRoman = text
                             } else if role == "x-bg" {
                                 currentBgLyric = BgTtmlLyric(subLyric: [], translation: nil, roman: nil)
                                 let bgSpanElements = try spanElement.getElementsByTag("span")
                                 for bgSpanElement in bgSpanElements {
                                     let bgBeginTime = try bgSpanElement.attr("begin")
                                     let bgEndTime = try bgSpanElement.attr("end")
                                     let bgSpanElementRole = try bgSpanElement.attr("ttm:role")
                                     var bgSpanElementText = try bgSpanElement.getPreservedText().normalizeSpaces()

                                     bgSpanElementText = bgSpanElementText.replacingOccurrences(of: "[()]", with: "", options: .regularExpression)

                                     if bgSpanElementRole == "x-translation" {
                                         currentBgLyric?.translation = bgSpanElementText
                                     } else if bgSpanElementRole == "x-roman" {
                                         currentBgLyric?.roman = bgSpanElementText
                                     } else if bgSpanElement.hasAttr("begin") {
                                         let bgSubTtmlLyric = SubTtmlLyric(
                                             beginTime: bgBeginTime.toTimeInterval(),
                                             endTime: bgEndTime.toTimeInterval(),
                                             text: bgSpanElementText
                                         )
                                         bgSubTtmlLyricList.append(bgSubTtmlLyric)
                                     }
                                     bgSubLyricsElements.append(bgSpanElement)
                                 }
                                 currentBgLyric?.subLyric = bgSubTtmlLyricList.isEmpty ? nil : bgSubTtmlLyricList
                             } else {
                                 if bgSubLyricsElements.contains(spanElement) { continue }
                                 let subLyricBeginTime = try spanElement.attr("begin")
                                 let subLyricEndTime = try spanElement.attr("end")
                                 let subTtmlLyric = SubTtmlLyric(
                                     beginTime: subLyricBeginTime.toTimeInterval(),
                                     endTime: subLyricEndTime.toTimeInterval(),
                                     text: try spanElement.getPreservedText().normalizeSpaces()
                                 )
                                 currentSubTtmlLyrics.append(subTtmlLyric)
                             }
                         }
                     }

                     currentTtmlLyric.mainLyric = currentSubTtmlLyrics
                     currentTtmlLyric.bgLyric = currentBgLyric
                     currentTtmlLyric.translation = currentTranslation
                     currentTtmlLyric.roman = currentRoman

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

 extension TTMLParser {
     private func getPositionFromAgent(_ agent: String) -> TtmlLyricPositionType {
         if agent == "v1" { return .main }
         return .sub
     }
 }

 // MARK: Extension
 extension String {
     func toTimeInterval() -> TimeInterval {
         let pattern = #"(\d+):(\d+)\.(\d+)"#
         let regex = try! NSRegularExpression(pattern: pattern)
         let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))

         guard let match = matches.first,
               match.numberOfRanges == 4,
               let minutesRange = Range(match.range(at: 1), in: self),
               let secondsRange = Range(match.range(at: 2), in: self),
               let millisecondsRange = Range(match.range(at: 3), in: self),
               let minutes = Double(self[minutesRange]),
               let seconds = Double(self[secondsRange]),
               let milliseconds = Double(self[millisecondsRange]) else {
             return TimeInterval(0)
         }

         let totalMilliseconds = (minutes * 60 + seconds) * 1000 + milliseconds
         let timeInterval = totalMilliseconds / 1000

         return timeInterval
     }
 }

 extension String {
     func normalizeSpaces() -> String {
         return self.replacingOccurrences(of: "\u{00A0}", with: " ")
                    .replacingOccurrences(of: "\u{2000}", with: " ")
                    .replacingOccurrences(of: "\u{2001}", with: " ")
                    .replacingOccurrences(of: "\u{2002}", with: " ")
                    .replacingOccurrences(of: "\u{2003}", with: " ")
                    .replacingOccurrences(of: "\u{2004}", with: " ")
                    .replacingOccurrences(of: "\u{2005}", with: " ")
                    .replacingOccurrences(of: "\u{2006}", with: " ")
                    .replacingOccurrences(of: "\u{2007}", with: " ")
                    .replacingOccurrences(of: "\u{2008}", with: " ")
                    .replacingOccurrences(of: "\u{2009}", with: " ")
                    .replacingOccurrences(of: "\u{200A}", with: " ")
     }
 }

 extension String.Encoding {
     public static let gbk: String.Encoding = {
         let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
         return String.Encoding(rawValue: gbkEncoding)
     }()
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

 */
