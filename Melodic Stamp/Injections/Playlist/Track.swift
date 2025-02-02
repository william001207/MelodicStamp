//
//  Track.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import AppKit
import CSFBAudioEngine
import Luminare
import SwiftUI

struct Track: Identifiable {
    let url: URL
    var metadata: Metadata!

    var id: URL { url }

    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
    }

    @MainActor init(loadingFrom url: URL, completion: (() -> ())? = nil) {
        self.url = url
        self.metadata = Metadata(loadingFrom: url, completion: completion)
    }

    @MainActor init(migratingFrom oldValue: Track, to url: URL?, useFallbackTitleIfNotProvided useFallbackTitle: Bool = false) throws {
        guard url != oldValue.url else {
            self = oldValue
            return
        }

        let url = url ?? oldValue.url
        self.url = url
        self.metadata = try Metadata(migratingFrom: oldValue.metadata, to: url, useFallbackTitleIfNotProvided: useFallbackTitle)
    }
}

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Track: Transferable {
    enum TransferError: Error, LocalizedError, CustomStringConvertible {
        case invalidURL(Data)
        case invalidFormat(URL)
        case notFileURL(URL)

        var description: String {
            switch self {
            case let .invalidURL(data):
                "(invalidURL) The received data does not represent a valid URL: \(data)."
            case let .invalidFormat(url):
                "(invalidFormat) The file format is not supported: \(url)."
            case let .notFileURL(url):
                "(notFileURL) The content behind the URL is not a file: \(url)."
            }
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .fileURL) { track in
            track.url.dataRepresentation
        } importing: { data in
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { throw TransferError.invalidURL(data) }
            guard url.isFileURL else { throw TransferError.notFileURL(url) }
            guard let url = FileHelper.filter(url: url) else { throw TransferError.invalidFormat(url) }

            return await Track(loadingFrom: url)
        }
    }
}
