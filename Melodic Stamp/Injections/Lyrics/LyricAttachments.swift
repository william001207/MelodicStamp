//
//  LyricAttachments.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

struct LyricAttachments: OptionSet, Hashable, Equatable, Codable {
    let rawValue: Int

    static let translation = LyricAttachments(rawValue: 1 << 0)
    static let roman = LyricAttachments(rawValue: 1 << 1)

    static let all: LyricAttachments = [.translation, .roman]
}
