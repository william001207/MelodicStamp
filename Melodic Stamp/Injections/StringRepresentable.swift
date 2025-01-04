//
//  StringRepresentable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/4.
//

import Foundation

protocol StringRepresentable {
    var stringRepresentation: String { get }

    static func wrappingUpdate(_ value: Self?, with stringRepresentation: String) -> Self?
}

extension String: StringRepresentable {
    var stringRepresentation: String { self }

    @inlinable
    static func wrappingUpdate(_: Self?, with stringRepresentation: String) -> Self? {
        stringRepresentation
    }
}
