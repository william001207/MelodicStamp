//
//  RawLyricLine.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation

struct RawLyricLine: LyricLine {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    var content: String

    let id: UUID = .init()
}
