//
//  TTMLTag.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

struct TTMLTag: Equatable, Hashable, Identifiable {
    enum TagType: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
        case begin
        case end
        case agent = "ttm:agent"
        case itunesKey = "itunes:key"
        case translation = "ttm:translation"
        case roman = "ttm:roman"

        var id: String { rawValue }

        var name: String {
            switch self {
            case .begin: .init(localized: "Begin")
            case .end: .init(localized: "End")
            case .agent: .init(localized: "Agent")
            case .itunesKey: .init(localized: "iTunes Key")
            case .translation: .init(localized: "Translation")
            case .roman: .init(localized: "Roman")
            }
        }

        static var regex: Regex<Substring> {
            Regex {
                ChoiceOf {
                    "begin"
                    "end"
                    "ttm:agent"
                    "itunes:key"
                    "ttm:translation"
                    "ttm:roman"
                }
            }
        }
    }

    var id: TagType { type }

    var type: TagType
    var content: String
}
