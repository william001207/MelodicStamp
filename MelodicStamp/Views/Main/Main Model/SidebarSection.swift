//
//  SidebarSection.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI
import SFSafeSymbols

struct SidebarSection: Hashable, Identifiable {
    let title: String? = nil
    let items: [SidebarTab]
    
    var id: Int {
        return self.hashValue
    }
    
    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

enum SidebarTab: Hashable, Identifiable, CaseIterable {
    case playlist
    case inspector
    case metadata
    
    var id: String {
        .init(describing: self)
    }
    
    var isComposable: Bool {
        switch self {
        case .playlist, .inspector, .metadata:
            true
        }
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
        }
    }
    
    var icon: Image {
        switch self {
        case .playlist:
                .init(systemSymbol: .musicNoteList)
        case .inspector:
                .init(systemSymbol: .photo)
        case .metadata:
                .init(systemSymbol: .textBadgePlus)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

//enum NavigationTarget: Hashable {
//    case artist(Artist)
//    case album(Album)
//    case playlist(Playlist)
//}
