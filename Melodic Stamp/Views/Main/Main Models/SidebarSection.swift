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

enum SidebarTab: String, Hashable, Identifiable, CaseIterable {
    case inspector
    case metadata
    case lyrics

    var id: String {
        rawValue
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
