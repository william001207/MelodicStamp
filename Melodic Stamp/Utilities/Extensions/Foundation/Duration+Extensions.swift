//
//  Duration+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

extension Duration {
    init(_ timeInterval: TimeInterval) {
        self = .seconds(timeInterval)
    }

    init?(length string: String) throws {
        let regex = /(\d+):(\d+)/

        guard let match = try regex.wholeMatch(in: string) else { return nil }

        guard
            let minutes = Double(match.output.1),
            let seconds = Double(match.output.2)
        else { return nil }

        self = .seconds(minutes * 60 + seconds)
    }
}
