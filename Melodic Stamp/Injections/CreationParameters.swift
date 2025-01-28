//
//  CreationParameters.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Foundation

struct CreationParameters: Hashable, Identifiable, Codable {
    var uniqueID = UUID()

    var playlist: PlaylistFactory = .referenced
    var shouldPlay: Bool = false
    var initialWindowStyle: MelodicStampWindowStyle = .main

    var id: UUID {
        switch playlist {
        case .referenced:
            uniqueID
        case let .canonical(id):
            id
        }
    }
}

extension CreationParameters {
    enum PlaylistFactory: Equatable, Hashable, Codable {
        case referenced([URL] = [])
        case canonical(UUID)

        static var referenced: Self { .referenced([]) }
    }
}
