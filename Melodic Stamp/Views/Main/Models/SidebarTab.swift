//
//  SidebarTab.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SFSafeSymbols
import SwiftUI

protocol SidebarTab: Hashable, Identifiable, Equatable {
    var title: String { get }
    var systemSymbol: SFSymbol { get }
}

enum SidebarContentTab: String, SidebarTab, CaseIterable, Codable {
    case playlist
    case leaflet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .playlist:
            .init(localized: "Playlist")
        case .leaflet:
            .init(localized: "Leaflet")
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
            [.commonMetadata, .advancedMetadata, .lyrics, .analysis]
        case .leaflet:
            [.analysis]
        }
    }
}

enum SidebarInspectorTab: String, SidebarTab, CaseIterable, Codable {
    case commonMetadata
    case advancedMetadata
    case lyrics
    case analysis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .commonMetadata:
            .init(localized: "Common")
        case .advancedMetadata:
            .init(localized: "Advanced")
        case .lyrics:
            .init(localized: "Lyrics")
        case .analysis:
            .init(localized: "Analysis")
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
        case .analysis:
            .checkmarkSealFill
        }
    }
}
