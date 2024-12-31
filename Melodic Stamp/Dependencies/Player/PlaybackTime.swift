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

    var remaining: TimeInterval { duration.timeInterval - elapsed }
    var progress: CGFloat { elapsed / duration.timeInterval }
}
