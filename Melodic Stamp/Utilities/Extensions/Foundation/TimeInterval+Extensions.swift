//
//  TimeInterval+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

extension TimeInterval {
    init?(timestamp string: String) throws {
        let prefixMillisecondsRegex = /(.+)\.(\d+)/
        let minutesSecondsRegex = /(\d+)\:(\d+)/

        guard
            let prefixMillisecondsMatch = try prefixMillisecondsRegex.wholeMatch(in: string),
            let milliseconds = Double(prefixMillisecondsMatch.output.2)
        else { return nil }
        let prefix = prefixMillisecondsMatch.output.1

        if let minutesSecondsMatch = try minutesSecondsRegex.wholeMatch(in: prefix) {
            guard
                let minutes = Double(minutesSecondsMatch.output.1),
                let seconds = Double(minutesSecondsMatch.output.2)
            else { return nil }

            self = minutes * 60 + seconds + milliseconds / 1000
        } else if let seconds = Double(prefix) {
            self = seconds + milliseconds / 1000
        } else {
            return nil
        }
    }

    init(_ duration: Duration) {
        let components = duration.components
        self = TimeInterval(components.seconds) + TimeInterval(components.attoseconds) * 1e-18
    }
}
