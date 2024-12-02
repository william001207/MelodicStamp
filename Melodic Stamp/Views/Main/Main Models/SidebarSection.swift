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
    case metadata
    case lyrics

    var id: String {
        rawValue
    }

    var opposites: [Self] {
        switch self {
        case .metadata:
            [.lyrics]
        case .lyrics:
            [.metadata]
        }
    }
}

enum SidebarTab: String, Hashable, Identifiable, CaseIterable {
    // composable - metadata
    case inspector
    case metadata

    // composable - lyrics
    case lyrics

    var id: String {
        rawValue
    }

    /// A larger number represents a stronger preference to stick to the trailing edge
    var order: Int {
        switch self {
        case .inspector: .max
        case .metadata: 0
        case .lyrics: 0
        }
    }

    var composable: SidebarComposable {
        switch self {
        case .inspector, .metadata:
            .metadata
        case .lyrics:
            .lyrics
        }
    }

    var opposites: [Self] {
        SidebarTab.allCases.filter {
            self.composable.opposites.contains($0.composable)
        }
    }

    var title: String {
        switch self {
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
        case .inspector:
            .photoOnRectangleAngled
        case .metadata:
            .textBadgePlus
        case .lyrics:
            .textQuote
        }
    }

    var material: NSVisualEffectView.Material {
        switch self {
        case .inspector:
            .titlebar
        case .metadata:
            .titlebar
        case .lyrics:
            .headerView
        }
    }
}
