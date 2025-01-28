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

    init?(loadingFrom url: URL, useFallbackTitleFrom fallbackURL: URL? = nil) async {
        self.url = url

        guard let metadata = await Metadata(loadingFrom: url, useFallbackTitleFrom: fallbackURL) else { return nil }
        self.metadata = metadata
    }

    init(migratingFrom oldValue: Track, withURL url: URL?, useFallbackTitleIfNotProvided useFallbackTitle: Bool = false) async {
        guard url != oldValue.url else {
            self = oldValue
            return
        }

        let url = url ?? oldValue.url
        self.url = url
        self.metadata = await .init(migratingFrom: oldValue.metadata, withURL: url, useFallbackTitleIfNotProvided: useFallbackTitle)
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
    enum TransferableError: Error, LocalizedError, CustomStringConvertible {
        case invalidURL(Data)
        case invalidFormat(URL)
        case notFileURL(URL)
        case failedToCreateTrack(URL)

        var description: String {
            switch self {
            case let .invalidURL(data):
                "(invalidURL) The received data does not represent a valid URL: \(data)."
            case let .invalidFormat(url):
                "(invalidFormat) The file format is not supported: \(url)."
            case let .notFileURL(url):
                "(notFileURL) The content behind the URL is not a file: \(url)."
            case let .failedToCreateTrack(url):
                "(failedToCreateTrack) Failed to create a track from the provided URL: \(url)."
            }
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .fileURL) { track in
            track.url.dataRepresentation
        } importing: { data in
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { throw TransferableError.invalidURL(data) }
            guard url.isFileURL else { throw TransferableError.notFileURL(url) }
            guard let url = FileHelper.filter(url: url) else { throw TransferableError.invalidFormat(url) }

            guard let track = await Track(loadingFrom: url) else { throw TransferableError.failedToCreateTrack(url) }
            return track
        }
    }
}
