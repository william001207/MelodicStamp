//
//  LyricsModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation
import RegexBuilder
import SwiftSoup

// MARK: - Lyric Line (Protocol)

protocol LyricLine: Equatable, Hashable, Identifiable {
    var beginTime: TimeInterval? { get }
    var endTime: TimeInterval? { get }

    var isValid: Bool { get }
}

extension LyricLine {
    var isValid: Bool {
        beginTime != nil || endTime != nil
    }
}

// MARK: - Lyrics Parser (Protocol)

protocol LyricsParser {
    associatedtype Line: LyricLine

    var lines: [Line] { get set }

    init(string: String) throws

    func highlight(at time: TimeInterval) -> Range<Int>

    func duration(of index: Int) -> (begin: TimeInterval?, end: TimeInterval?)

    func duration(before index: Int) -> (begin: TimeInterval?, end: TimeInterval?)
}

extension LyricsParser {
    // Do not use sequences, otherwise causing huge performance issues
    func highlight(at time: TimeInterval) -> Range<Int> {
        let endIndex = lines.endIndex
        let suspensionThreshold: TimeInterval = 4

        let previous = lines.last {
            if let beginTime = $0.beginTime {
                beginTime <= time
            } else { false }
        }
        let previousIndex = previous.flatMap(lines.firstIndex)

        if let previous, let previousIndex, let beginTime = previous.beginTime {
            // Has a prefixing line

            if let endTime = previous.endTime {
                // The prefixing line specifies an ending time

                let reachedEndTime = endTime < time

                if reachedEndTime {
                    // Reached the prefixing line's ending time

                    let next = lines.first {
                        if let beginTime = $0.beginTime {
                            beginTime > time
                        } else { false }
                    }
                    let nextIndex = next.flatMap(lines.firstIndex)

                    if let next, let nextIndex {
                        // Has a suffixing line

                        let shouldSuspend = if let beginTime = next.beginTime {
                            beginTime - endTime >= suspensionThreshold
                        } else { false }

                        return if shouldSuspend {
                            // Suspend before the suffixing line begins
                            nextIndex ..< nextIndex
                        } else {
                            // Present the suffixing line in advance
                            nextIndex ..< (nextIndex + 1)
                        }
                    } else {
                        // Has no suffixing lines

                        return endIndex ..< endIndex
                    }
                } else {
                    // Still in the range of the prefixing line

                    let furthest = lines.first {
                        if let endTime = $0.endTime {
                            endTime > beginTime
                        } else { false }
                    }
                    let furthestIndex = furthest.flatMap(lines.firstIndex)

                    return if let furthestIndex {
                        furthestIndex ..< (previousIndex + 1)
                    } else {
                        0 ..< (previousIndex + 1)
                    }
                }
            } else {
                // The prefixing line specifies no ending times

                let next = lines.first {
                    if let beginTime = $0.beginTime {
                        beginTime > time
                    } else { false }
                }
                let nextIndex = next.flatMap(lines.firstIndex)

                if let nextIndex {
                    // Has a suffixing line

                    return previousIndex ..< nextIndex
                } else {
                    // Has no suffixing lines

                    let furthest = lines.first {
                        if let endTime = $0.endTime {
                            endTime > beginTime
                        } else { false }
                    }
                    let furthestIndex = furthest.flatMap(lines.firstIndex)

                    return if let furthestIndex {
                        furthestIndex ..< (previousIndex + 1)
                    } else {
                        0 ..< (previousIndex + 1)
                    }
                }
            }
        } else {
            // Has no prefixing lines
            
            let next = lines.first
            
            if let next {
                // Has a suffixing line
                
                let shouldSuspend = if let beginTime = next.beginTime {
                    beginTime >= suspensionThreshold
                } else { false }
                
                return if shouldSuspend {
                    // Suspend before the suffixing line begins
                    0 ..< 0
                } else {
                    // Present the suffixing line in advance
                    0 ..< 1
                }
            } else {
                // Has no suffixing lines
                
                return endIndex ..< endIndex
            }
        }
    }

    func duration(of index: Int) -> (begin: TimeInterval?, end: TimeInterval?) {
        guard lines.indices.contains(index) else { return (nil, nil) }
        return (lines[index].beginTime, lines[index].endTime)
    }

    func duration(before index: Int) -> (begin: TimeInterval?, end: TimeInterval?) {
        guard lines.indices.contains(index) else { return (nil, nil) }
        let duration = duration(of: index)

        if let time = duration.begin {
            let previous = lines.last {
                if let beginTime = $0.beginTime {
                    beginTime < time
                } else { false }
            }

            return (previous?.endTime, time)
        } else {
            return (nil, nil)
        }
    }
}

// MARK: - Lyrics Type

enum LyricsType: String, Hashable, Identifiable, CaseIterable {
    case raw // Raw splitted string, unparsed
    case lrc // Line based
    case ttml // Word based

    var id: String {
        rawValue
    }
}

// MARK: - Lyrics Storage

enum LyricsStorage {
    case raw(parser: RawLyricsParser)
    case lrc(parser: LRCParser)
    case ttml(parser: TTMLParser)

    var type: LyricsType {
        switch self {
        case .raw: .raw
        case .lrc: .lrc
        case .ttml: .ttml
        }
    }

    var parser: any LyricsParser {
        switch self {
        case let .raw(parser):
            parser
        case let .lrc(parser):
            parser
        case let .ttml(parser):
            parser
        }
    }
}

// MARK: - Raw Lyrics

struct RawLyrics: Hashable, Equatable, Identifiable {
    let url: URL
    var content: String?

    var id: URL { url }
}

// MARK: - Lyrics Model

@Observable class LyricsModel {
    private(set) var storage: LyricsStorage?
    private(set) var raw: RawLyrics?
    var type: LyricsType?

    var lines: [any LyricLine] {
        storage?.parser.lines ?? []
    }

    func read(_ raw: RawLyrics?, autoRecognizes: Bool = true, forced: Bool = false) async {
        guard forced || raw != self.raw else { return }
        self.raw = raw

        guard let raw else {
            // Explicitly set to nothing
            storage = nil
            type = nil
            return
        }

        guard let content = raw.content else {
            // Implicitly fails, reading nothing
            storage = nil
            type = nil
            return
        }

        if autoRecognizes {
            do {
                type = try recognize(string: content) ?? .raw
            } catch {
                type = .raw
            }
        }

        if let type {
            do {
                storage = switch type {
                case .raw:
                    try .raw(parser: .init(string: content))
                case .lrc:
                    try .lrc(parser: .init(string: content))
                case .ttml:
                    try .ttml(parser: .init(string: content))
                }
            } catch {
                storage = nil
            }
        }
    }

    func highlight(at time: TimeInterval, in url: URL? = nil) -> Range<Int> {
        guard let storage else { return 0 ..< 0 }
        let result = storage.parser.highlight(at: time)
        return if let url {
            if url == raw?.url {
                result
            } else {
                0 ..< 0
            }
        } else {
            result
        }
    }
}

extension LyricsModel {
    func recognize(string: String?) throws -> LyricsType? {
        guard let string else { return nil }
        return if string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .starts(with: /\[.+].*/) {
            .lrc
        } else if
            let body = try SwiftSoup.parse(string).body(),
            try !body.getElementsByTag("tt").isEmpty {
            .ttml
        } else {
            .raw
        }
    }
}
