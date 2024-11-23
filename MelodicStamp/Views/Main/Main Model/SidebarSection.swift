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
    let items: [SidebarItem]
    
    var id: Int {
        return self.hashValue
    }
    
    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

enum SidebarItem: Hashable, Identifiable, CaseIterable {
    case home
    case search
    case library
    case setting
    
    var id: String {
        .init(describing: self)
    }
    
    var title: String {
        switch self {
        case .home:
                .init(localized: "Home")
        case .search:
                .init(localized: "Search")
        case .library:
                .init(localized: "Library")
        case .setting:
                .init(localized: "Settings")
        }
    }
    
    var icon: Image {
        switch self {
        case .home:
                .init(systemSymbol: .house)
        case .search:
                .init(systemSymbol: .magnifyingglass)
        case .library:
                .init(systemSymbol: .playSquareStack)
        case .setting:
                .init(systemSymbol: .gearshape)
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
