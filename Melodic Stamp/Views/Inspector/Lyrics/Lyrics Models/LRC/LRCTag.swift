//
//  LRCTag.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

struct LRCTag: Hashable, Equatable, Identifiable {
    enum TagType: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creator = "by"
        case offset
        case editor = "re"
        case version = "ve"
        case translation = "tr"

        var id: String { rawValue }

        var isMetadata: Bool {
            switch self {
            case .length, .offset, .translation: true
            default: false
            }
        }

        var name: String {
            switch self {
            case .length: .init(localized: "Length")
            case .offset: .init(localized: "Offset")
            case .translation: .init(localized: "Translation")
            case .artist: .init(localized: "Artist")
            case .album: .init(localized: "Album")
            case .title: .init(localized: "Title")
            case .author: .init(localized: "Author")
            case .creator: .init(localized: "Creator")
            case .editor: .init(localized: "Editor")
            case .version: .init(localized: "Version")
            }
        }

        static var regex: Regex<Substring> {
            Regex {
                ChoiceOf {
                    length.rawValue
                    offset.rawValue
                    translation.rawValue

                    artist.rawValue
                    album.rawValue
                    title.rawValue
                    author.rawValue
                    creator.rawValue
                    editor.rawValue
                    version.rawValue
                }
            }
        }
    }

    var id: TagType { type }

    var type: TagType
    var content: String
}
