//
//  UUID+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/14.
//

import Foundation

extension UUID {
    struct FormatStyle: Hashable, Equatable, Codable, ParseableFormatStyle {
        typealias FormatInput = UUID
        typealias FormatOutput = String

        struct Strategy: ParseStrategy {
            typealias ParseInput = String
            typealias ParseOutput = UUID

            func parse(_ value: String) throws -> UUID {
                if let uuid = UUID(uuidString: value) {
                    return uuid
                } else {
                    throw FormatError.invalidFormat
                }
            }
        }

        enum FormatError: Error {
            case invalidFormat
        }

        var parseStrategy: Strategy = .init()

        func format(_ value: UUID) -> String {
            value.uuidString
        }
    }
}

extension FormatStyle where Self == UUID.FormatStyle {
    static var uuid: Self {
        uuid()
    }

    static func uuid(parseStrategy: Self.Strategy = .init()) -> Self {
        .init(parseStrategy: parseStrategy)
    }
}
