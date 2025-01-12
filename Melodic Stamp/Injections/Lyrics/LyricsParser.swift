//
//  LyricsParser.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

// MARK: - Lyrics Parser (Protocol)

protocol LyricsParser {
    associatedtype Line: LyricLine

    var lines: [Line] { get }
    var attachments: LyricAttachments { get }
    var metadata: [LyricsMetadata] { get }

    init(string: String) throws

    func highlight(at time: TimeInterval) -> Range<Int>

    func duration(of index: Int) -> (begin: TimeInterval?, end: TimeInterval?)

    func duration(before index: Int) -> (begin: TimeInterval?, end: TimeInterval?)
}

extension LyricsParser {
    var attachments: LyricAttachments { [] }
    var metadata: [LyricsMetadata] { [] }

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
                        previousIndex ..< (previousIndex + 1)
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
                        previousIndex ..< (previousIndex + 1)
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
            if index > 0 {
                let previous = lines.last {
                    if let beginTime = $0.beginTime {
                        beginTime < time
                    } else { false }
                }

                return (previous?.endTime, time)
            } else {
                return (.zero, time)
            }
        } else {
            return (nil, nil)
        }
    }
}

// MARK: - Lyrics Type

enum LyricsType: String, Hashable, CaseIterable, Identifiable {
    case raw // Raw splitted string, unparsed
    case lrc // Line based
    case ttml // Word based

    var id: Self { self }
}
