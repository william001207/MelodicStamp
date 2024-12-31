//
//  PlaybackMode.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation
import SwiftUI

enum PlaybackMode: String, Hashable, Equatable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case sequential
    case loop
    case shuffle

    var image: Image {
        switch self {
        case .sequential:
            .init(systemSymbol: .musicNoteList)
        case .loop:
            .init(systemSymbol: .repeat)
        case .shuffle:
            .init(systemSymbol: .shuffle)
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
