//
//  ISRC.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/14.
//

import Foundation

struct ISRC: Hashable, Equatable, Codable {
    var countryCode: String // 2 digits
    var registrantCode: String // 3 digits
    var year: String // 2 digits
    var designationCode: String // 5 digits

    var components: [String] {
        [countryCode, registrantCode, year, designationCode]
    }

    init(
        countryCode: String, registrantCode: String, year: String,
        designationCode: String
    ) {
        self.countryCode = countryCode
        self.registrantCode = registrantCode
        self.year = year
        self.designationCode = designationCode
    }

    init?(parsing value: String, parseStrategy: FormatStyle.Strategy = .init()) {
        do {
            self = try parseStrategy.parse(value)
        } catch {
            return nil
        }
    }
}

extension ISRC {
    struct FormatStyle: Hashable, Equatable, Codable, ParseableFormatStyle {
        typealias FormatInput = ISRC
        typealias FormatOutput = String

        struct Strategy: ParseStrategy {
            typealias ParseInput = String
            typealias ParseOutput = ISRC

            func parse(_ value: String) throws -> ISRC {
                let components = value.uppercased().split(separator: "-")
                guard components.count == 4,
                      components[0].count == 2,
                      components[1].count == 3,
                      components[2].count == 2,
                      components[3].count == 5,
                      components.allSatisfy({
                          $0.allSatisfy(\.isNumber) || $0.allSatisfy(\.isLetter)
                      })
                else {
                    throw FormatError.invalidFormat
                }

                return .init(
                    countryCode: String(components[0]),
                    registrantCode: String(components[1]),
                    year: String(components[2]),
                    designationCode: String(components[3])
                )
            }
        }

        enum FormatError: Error {
            case invalidFormat
        }

        var parseStrategy: Strategy = .init()

        func format(_ value: ISRC) -> String {
            value.components.joined(separator: "-")
        }
    }
}

extension ISRC {
    func formatted(parseStrategy: FormatStyle.Strategy = .init()) -> String {
        Self.FormatStyle(parseStrategy: parseStrategy).format(self)
    }

    func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
        where F.FormatInput == ISRC {
        style.format(self)
    }
}

extension FormatStyle where Self == ISRC.FormatStyle {
    static var isrc: Self {
        isrc()
    }

    static func isrc(parseStrategy: Self.Strategy = .init()) -> Self {
        .init(parseStrategy: parseStrategy)
    }
}
