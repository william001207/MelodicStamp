//
//  BookmarkedURLs.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Foundation

typealias BookmarkedURLs = [URL]

// Do not use security scope options, otherwise causing hard crashes, reasons unknown
extension BookmarkedURLs: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        do {
            guard let data = Data(base64Encoded: rawValue) else { return nil }
            guard let bookmarks = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Data] else { return nil }

            self = try bookmarks.compactMap {
                var isStale = false
                let url = try URL(resolvingBookmarkData: $0, options: [], bookmarkDataIsStale: &isStale)
                return isStale ? nil : url
            }
        } catch {
            fatalError("Failed to decode \(Self.self) from \(rawValue): \(error)")
        }
    }

    public var rawValue: String {
        do {
            let bookmarks: [Data] = try compactMap { try $0.bookmarkData() }
            let data = try PropertyListSerialization.data(fromPropertyList: bookmarks, format: .binary, options: .zero)
            return data.base64EncodedString()
        } catch {
            fatalError("Failed to encode \(self): \(error)")
        }
    }
}
