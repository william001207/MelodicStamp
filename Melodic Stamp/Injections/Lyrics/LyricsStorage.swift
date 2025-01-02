//
//  LyricsStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

enum LyricsStorage {
    case raw(parser: RawLyricsParser)
    case lrc(parser: LRCParser)
    case ttml(parser: TTMLParser)

    var type: LyricsType {
        switch self {
        case .raw: .raw
        case .lrc: .lrc
        case .ttml: .ttml
        }
    }

    var parser: any LyricsParser {
        switch self {
        case let .raw(parser):
            parser
        case let .lrc(parser):
            parser
        case let .ttml(parser):
            parser
        }
    }
}
