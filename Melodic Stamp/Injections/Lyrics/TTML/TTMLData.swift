//
//  TTMLData.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/15.
//

import RegexBuilder
import SFSafeSymbols
import SwiftSoup
import SwiftUI

// MARK: - Data

enum TTMLData: Equatable, Hashable, Identifiable {
    enum Key: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
        case begin
        case end
        case agent = "ttm:agent"
        case role = "ttm:role"
        case itunesKey = "itunes:key"
        case language = "xml:lang"

        var id: String { rawValue }
    }

    case begin(TimeInterval)
    case end(TimeInterval)
    case agent(TTMLPosition)
    case role(TTMLRole)
    case itunesKey(String)
    case language(TTMLLocale)

    var id: Key { key }

    var key: Key {
        switch self {
        case .begin: .begin
        case .end: .end
        case .agent: .agent
        case .role: .role
        case .itunesKey: .itunesKey
        case .language: .language
        }
    }

    init?(key: Key, element: Element) throws {
        try self.init(key: key, rawValue: element.attr(key.rawValue))
    }

    init?(key: Key, rawValue: String) throws {
        switch key {
        case .begin:
            guard let time = try TimeInterval(timestamp: rawValue) else { return nil }
            self = .begin(time)
        case .end:
            guard let time = try TimeInterval(timestamp: rawValue) else { return nil }
            self = .end(time)
        case .agent:
            guard let position = TTMLPosition(agent: rawValue) else { return nil }
            self = .agent(position)
        case .role:
            guard let role = TTMLRole(rawValue: rawValue) else { return nil }
            self = .role(role)
        case .itunesKey: self = .itunesKey(rawValue)
        case .language:
            let locale = TTMLLocale(identifier: rawValue)
            self = .language(locale)
        }
    }
}

// MARK: - Position

enum TTMLPosition: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case main
    case sub

    var id: String { rawValue }

    init?(agent: String) {
        switch agent {
        case "v1":
            self = .main
        case "v2":
            self = .sub
        default:
            return nil
        }
    }
}

// MARK: - Role

enum TTMLRole: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case translation = "x-translation"
    case roman = "x-roman"
    case background = "x-bg"

    var id: String { rawValue }
}

// MARK: - Locale

typealias TTMLLocale = Locale

extension TTMLLocale {
    var main: String? {
        identifier.split(separator: /[-_]/).first.map(String.init)
    }

    var symbolLocalization: Localization? {
        main.flatMap(Localization.init(rawValue:))
    }

    func localize(systemSymbol symbol: SFSymbol) -> SFSymbol? {
        symbolLocalization.flatMap(symbol.localized(to:))
    }
}
