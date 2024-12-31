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
    case analytics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .commonMetadata:
            .init(localized: "Common")
        case .advancedMetadata:
            .init(localized: "Advanced")
        case .lyrics:
            .init(localized: "Lyrics")
        case .analytics:
            .init(localized: "Analytics")
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
        case .analytics:
            .checkmarkSealFill
        }
    }
}
