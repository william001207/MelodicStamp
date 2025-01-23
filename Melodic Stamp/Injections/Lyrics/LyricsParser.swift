//
//  LyricsParser.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

// MARK: - Lyrics Parser (Protocol)

protocol LyricsParser: Hashable, Equatable {
    associatedtype Line: LyricLine

    var lines: [Line] { get }
    var attachments: LyricsAttachments { get }
    var metadata: [LyricsMetadata] { get }

    init(string: String) throws

    func highlight(at time: TimeInterval) -> Range<Int>

    func duration(of index: Int) -> (begin: TimeInterval?, end: TimeInterval?)

    func duration(before index: Int) -> (begin: TimeInterval?, end: TimeInterval?)
}

extension LyricsParser {
    var attachments: LyricsAttachments { [] }
    var metadata: [LyricsMetadata] { [] }

    // Do not use sequences, otherwise causing huge performance issues
    func highlight(at time: TimeInterval) -> Range<Int> {
        let endIndex = lines.endIndex
        let suspensionThreshold: TimeInterval = 4

        let current = lines.last {
            guard let beginTime = $0.beginTime else { return false }
            return beginTime <= time
        }
        let currentIndex = current.flatMap(lines.firstIndex)

        if let current, let currentIndex, let currentBeginTime = current.condensedBeginTime {
            // Has a valid line for highlighting

            // Gets the furthest preceding line that is eligible for highlighting
            // Equals to the first of the consecutive preceding lines that have ending times greater than current line's beginning time
            let furthestPreceding = lines.reversed()
                .drop {
                    guard let beginTime = $0.beginTime else { return true }
                    return beginTime >= currentBeginTime
                }
                .prefix {
                    guard let endTime = $0.condensedEndTime else { return false }
                    return endTime > currentBeginTime
                }
                .first
            let furthestPrecedingIndex = furthestPreceding.flatMap(lines.firstIndex)

            if let currentEndTime = current.endTime {
                // Current line specifies a valid ending time

                let reachedEndTime = currentEndTime < time

                if reachedEndTime {
                    // Current line has ended

                    let succeeding = lines.first {
                        if let beginTime = $0.beginTime {
                            beginTime > time
                        } else { false }
                    }
                    let succeedingIndex = succeeding.flatMap(lines.firstIndex)

                    if let succeeding, let succeedingIndex {
                        // Has a valid succeeding line

                        let shouldSuspend = if let beginTime = succeeding.beginTime {
                            beginTime - currentEndTime >= suspensionThreshold
                        } else { false }

                        return if shouldSuspend {
                            // Suspend before the succeeding line begins
                            succeedingIndex ..< succeedingIndex
                        } else {
                            // Present the succeeding line in advance
                            succeedingIndex ..< (succeedingIndex + 1)
                        }
                    } else {
                        // Has no succeeding lines

                        return endIndex ..< endIndex
                    }
                } else {
                    // Still in the range of current line

                    return if let furthestPrecedingIndex {
                        furthestPrecedingIndex ..< (currentIndex + 1)
                    } else {
                        currentIndex ..< (currentIndex + 1)
                    }
                }
            } else {
                // Current line specifies no ending time

                let next = lines.first {
                    if let beginTime = $0.beginTime {
                        beginTime > time
                    } else { false }
                }
                let nextIndex = next.flatMap(lines.firstIndex)

                if let nextIndex {
                    // Has a valid succeeding line

                    return currentIndex ..< nextIndex
                } else {
                    // Has no succeeding lines

                    return if let furthestPrecedingIndex {
                        furthestPrecedingIndex ..< (currentIndex + 1)
                    } else {
                        currentIndex ..< (currentIndex + 1)
                    }
                }
            }
        } else {
            // Has no valid lines for highlighting, often indicating the start of a song

            let next = lines.first

            if let next {
                // Has a valid succeeding line

                let shouldSuspend = if let beginTime = next.beginTime {
                    beginTime >= suspensionThreshold
                } else { false }

                return if shouldSuspend {
                    // Suspend before the succeeding line begins
                    0 ..< 0
                } else {
                    // Present the succeeding line in advance
                    0 ..< 1
                }
            } else {
                // Has no succeeding lines

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
