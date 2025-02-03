//
//  LyricsAttachments.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation

struct LyricsAttachments: OptionSet, Hashable, Equatable, Codable {
    let rawValue: Int

    static let translation = LyricsAttachments(rawValue: 1 << 0)
    static let roman = LyricsAttachments(rawValue: 1 << 1)

    static let all: LyricsAttachments = [.translation, .roman]
}
