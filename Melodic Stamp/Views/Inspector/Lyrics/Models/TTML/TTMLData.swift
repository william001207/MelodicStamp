//
//  TTMLData.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/15.
//

import Foundation
import RegexBuilder
import SwiftSoup

struct TTMLData: Equatable, Hashable, Identifiable {
    enum DataType: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
        case begin
        case end
        case agent = "ttm:agent"
        case role = "ttm:role"
        case itunesKey = "itunes:key"

        var id: String { rawValue }
    }

    var id: DataType { type }

    var type: DataType
    var content: String

    init(type: DataType, content: String) {
        self.type = type
        self.content = content
    }

    init?(type: DataType, element: Element) throws {
        try self.init(type: type, content: element.attr(type.rawValue))
    }
}

enum TTMLRole: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case translation = "x-translation"
    case roman = "x-roman"
    case background = "x-bg"

    var id: String { rawValue }
}
