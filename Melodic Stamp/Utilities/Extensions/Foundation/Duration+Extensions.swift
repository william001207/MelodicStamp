//
//  Duration+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import Foundation

extension Duration {
    func toTimeInterval() -> TimeInterval {
        let components = components
        return TimeInterval(components.seconds) + TimeInterval(components.attoseconds) * 1e-18
    }
}
