//
//  LRCTag.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder

enum LRCTag: Hashable, Equatable, Identifiable {
    enum Key: String, Hashable, Equatable, CaseIterable, Identifiable, Codable {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creator = "by"
        case offset
        case editor = "re"
        case tool
        case vertion = "ve"
        case translation = "tr"

        var id: Self { self }
    }

    case artist(String)
    case album(String)
    case title(String)
    case author(String)
    case length(Duration)
    case creator(String)
    case offset(TimeInterval)
    case editor(String)
    case tool(String)
    case version(String)
    case translation(String)

    init?(key: Key, rawValue: String) throws {
        switch key {
        case .artist: self = .artist(rawValue)
        case .album: self = .album(rawValue)
        case .title: self = .title(rawValue)
        case .author: self = .author(rawValue)
        case .length:
            guard let duration = try Duration(length: rawValue) else { return nil }
            self = .length(duration)
        case .creator: self = .creator(rawValue)
        case .offset:
            guard let time = try TimeInterval(timestamp: rawValue) else { return nil }
            self = .offset(time)
        case .editor: self = .editor(rawValue)
        case .tool: self = .tool(rawValue)
        case .vertion: self = .version(rawValue)
        case .translation: self = .translation(rawValue)
        }
    }

    var id: Key { key }

    var key: Key {
        switch self {
        case .artist: .artist
        case .album: .album
        case .title: .title
        case .author: .author
        case .length: .length
        case .creator: .creator
        case .offset: .offset
        case .editor: .editor
        case .tool: .tool
        case .version: .vertion
        case .translation: .translation
        }
    }

    static var regex: Regex<Substring> {
        Regex {
            ChoiceOf {
                Key.artist.rawValue
                Key.album.rawValue
                Key.title.rawValue
                Key.author.rawValue
                Key.length.rawValue
                Key.creator.rawValue
                Key.offset.rawValue
                Key.editor.rawValue
                Key.tool.rawValue
                Key.vertion.rawValue
                Key.translation.rawValue
            }
        }
    }
}
