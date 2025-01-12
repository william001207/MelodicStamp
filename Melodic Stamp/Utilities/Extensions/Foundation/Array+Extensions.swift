//
//  Array+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Foundation

extension Array {
    /// Blends an array of `[A, B, C]` to `[A, AB, B, BC, C, CA]` using a transformation function, which blends `A, B` into `AB`, etc.
    func blending(transform: @escaping (Element, Element) -> Element) -> Self {
        guard count > 1 else { return self }
        var result: Self = []

        for i in 0 ..< count {
            let current = self[i]
            let next = self[(i + 1) % count] // Cyclomatic transition
            result.append(current)
            result.append(transform(current, next)) // Insert blended element
        }

        return result
    }
}

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: Data) {
        do {
            self = try JSONDecoder().decode(Self.self, from: rawValue)
        } catch {
            fatalError("Failed to decode \(Self.self) from \(rawValue): \(error)")
        }
    }

    public var rawValue: Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            return try encoder.encode(self)
        } catch {
            fatalError("Failed to encode \(self): \(error)")
        }
    }
}
