//
//  SidebarSection.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SFSafeSymbols
import SwiftUI

struct SidebarSection: Hashable, Identifiable {
    var title: String? = nil
    var tabs: [SidebarTab]

    var id: Int {
        return hashValue
    }

    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

enum SidebarComposable: String, Hashable, Identifiable, CaseIterable {
    case playlist
    case metadata
    case lyrics

    var id: String {
        rawValue
    }

    var opposites: [Self] {
        switch self {
        case .playlist:
            []
        case .metadata:
            [.lyrics]
        case .lyrics:
            [.metadata]
        }
    }
}

enum SidebarTab: String, Hashable, Identifiable, CaseIterable {
    case playlist

    // composable - metadata
    case inspector
    case metadata

    // composable - lyrics
    case lyrics

    var id: String {
        rawValue
    }

    var composable: SidebarComposable {
        switch self {
        case .playlist:
            .playlist
        case .inspector, .metadata:
            .metadata
        case .lyrics:
            .lyrics
        }
    }

    var opposites: [Self] {
        SidebarTab.allCases.filter { self.composable.opposites.contains($0.composable) }
    }

    /// A larger value prefers a place closer to the trailing edge.
    var order: Int {
        switch self {
        case .playlist:
            0
        case .inspector:
            2
        case .metadata:
            1
        case .lyrics:
            1
        }
    }

    var title: String {
        switch self {
        case .playlist:
            .init(localized: "Playlist")
        case .inspector:
            .init(localized: "Inspector")
        case .metadata:
            .init(localized: "Metadata")
        case .lyrics:
            .init(localized: "Lyrics")
        }
    }

    var systemSymbol: SFSymbol {
        switch self {
        case .playlist:
            .musicNoteList
        case .inspector:
            .photoOnRectangleAngled
        case .metadata:
            .textBadgePlus
        case .lyrics:
            .textQuote
        }
    }
}
