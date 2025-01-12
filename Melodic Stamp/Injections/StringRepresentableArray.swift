//
//  StringRepresentableArray.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Foundation

typealias StringRepresentableArray<Element> = [Element] where Element: Codable

extension StringRepresentableArray: RawRepresentable {
    public init?(rawValue: String) {
        do {
            guard let data = rawValue.data(using: .utf8) else { return nil }
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            fatalError("Failed to decode \(Self.self) from \(rawValue): \(error)")
        }
    }

    public var rawValue: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            fatalError("Failed to encode \(self): \(error)")
        }
    }
}
