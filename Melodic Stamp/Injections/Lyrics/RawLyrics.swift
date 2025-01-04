//
//  RawLyrics.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

struct RawLyrics: Hashable, Equatable, Identifiable {
    let url: URL
    var content: String?

    var id: URL { url }
}

extension RawLyrics: StringRepresentable {
    var stringRepresentation: String { content ?? "" }

    static func wrappingUpdate(_ value: RawLyrics?, with stringRepresentation: String) -> RawLyrics? {
        if let value {
            .init(url: value.url, content: stringRepresentation)
        } else {
            nil
        }
    }
}
