//
//  PlaybackMode.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation
import SFSafeSymbols
import SwiftUI

enum PlaybackMode: String, Hashable, Equatable, CaseIterable, Identifiable, Codable {
    case sequential
    case loop
    case shuffle

    var id: Self { self }

    var systemSymbol: SFSymbol {
        switch self {
        case .sequential:
            .musicNoteList
        case .loop:
            .repeat
        case .shuffle:
            .shuffle
        }
    }

    func cycle(negate: Bool = false) -> Self {
        switch self {
        case .sequential:
            negate ? .shuffle : .loop
        case .loop:
            negate ? .sequential : .shuffle
        case .shuffle:
            negate ? .loop : .sequential
        }
    }
}
