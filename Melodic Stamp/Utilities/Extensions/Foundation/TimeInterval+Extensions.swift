//
//  TimeInterval+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

extension TimeInterval {
    init?(lyricTimestamp string: String) throws {
        let regex = /^(\d+):(\d+)\.(\d+)$/

        guard let match = try regex.wholeMatch(in: string) else { return nil }
        // output: (original, first, second, third)

        let components = [match.output.1, match.output.2, match.output.3]
            .compactMap { Int($0) }
        guard components.count == 3 else { return nil }

        let minutes = Double(components[0]), seconds = Double(components[1]), milliseconds = Double(components[2])
        self.init(floatLiteral: minutes * 60 + seconds + milliseconds / 1000)
    }

    var duration: Duration {
        .seconds(self)
    }
}
