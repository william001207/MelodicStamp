//
//  SidebarContentTab.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import SFSafeSymbols
import SwiftUI

enum SidebarContentTab: String, SidebarTab, CaseIterable, Codable {
    case playlist
    case leaflet

    var id: Self { self }

    var title: String {
        switch self {
        case .playlist:
            String(localized: "Playlist")
        case .leaflet:
            String(localized: "Leaflet")
        }
    }

    var systemSymbol: SFSymbol {
        switch self {
        case .playlist:
            .musicNoteList
        case .leaflet:
            .viewfinder
        }
    }

    var inspectors: [SidebarInspectorTab] {
        switch self {
        case .playlist:
            [.commonMetadata, .advancedMetadata, .lyrics, .library /* , .analytics */ ]
        case .leaflet:
            [.library /* , .analytics */ ]
        }
    }
}
