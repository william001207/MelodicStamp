//
//  PlaybackTime.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

struct PlaybackTime: Hashable {
    private(set) var duration: Duration = .zero
    private(set) var elapsed: TimeInterval = .zero

    var remaining: TimeInterval { TimeInterval(duration) - elapsed }
    var progress: CGFloat { elapsed / TimeInterval(duration) }
}
