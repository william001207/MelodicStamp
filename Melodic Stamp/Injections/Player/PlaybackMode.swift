//
//  PlaybackMode.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation
import SFSafeSymbols
import SwiftUI

enum PlaybackMode: String, Hashable, Equatable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case sequential
    case loop
    case shuffle

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
