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

@Observable final class Track: Identifiable {
    let url: URL
    var metadata: Metadata

    var id: URL { url }

    init?(url: URL) {
        self.url = url

        guard let metadata = Metadata(url: url) else { return nil }
        self.metadata = metadata
    }

    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
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
    enum TransferableError: Error {
        case invalidURL
        case failedToReadURL
        case failedToCreateTrack
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .fileURL) { track in
            print(track.url)
            return track.url.dataRepresentation
        } importing: { data in
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { throw TransferableError.invalidURL }
            guard url.startAccessingSecurityScopedResource() else { throw TransferableError.failedToReadURL }

            guard let track = Track(url: url) else { throw TransferableError.failedToCreateTrack }
            return track
        }
    }
}
