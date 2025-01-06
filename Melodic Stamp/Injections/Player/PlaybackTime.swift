//
//  PlaybackTime.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

struct PlaybackTime: Hashable {
    fileprivate(set) var duration: Duration = .zero
    fileprivate(set) var elapsed: TimeInterval = .zero

    var remaining: TimeInterval { TimeInterval(duration) - elapsed }
    var progress: CGFloat { elapsed / TimeInterval(duration) }
}
