//
//  SidebarInspectorTab.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import SFSafeSymbols
import SwiftUI

enum SidebarInspectorTab: String, SidebarTab, CaseIterable, Codable {
    case commonMetadata
    case advancedMetadata
    case lyrics
    case library
    case analytics

    var id: Self { self }

    var title: String {
        switch self {
        case .commonMetadata:
            String(localized: "Common")
        case .advancedMetadata:
            String(localized: "Advanced")
        case .lyrics:
            String(localized: "Lyrics")
        case .library:
            String(localized: "Library")
        case .analytics:
            String(localized: "Analytics")
        }
    }

    var systemSymbol: SFSymbol {
        switch self {
        case .commonMetadata:
            .photoOnRectangleAngled
        case .advancedMetadata:
            .at
        case .lyrics:
            .textQuote
        case .library:
            .buildingColumns
        case .analytics:
            .checkmarkSeal
        }
    }
}
