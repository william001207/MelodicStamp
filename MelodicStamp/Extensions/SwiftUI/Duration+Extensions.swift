//
//  Duration+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/22.
//

import SwiftUI

extension Duration {
    func toTimeInterval() -> TimeInterval {
        let components = self.components
        return TimeInterval(components.seconds) + TimeInterval(components.attoseconds) * 1e-18
    }
}
