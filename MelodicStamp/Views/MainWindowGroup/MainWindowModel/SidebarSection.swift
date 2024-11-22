//
//  SidebarSection.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Foundation
import SwiftUI

struct SidebarSection: Hashable, Identifiable {
    let title: String?
    let items: [SidebarItem]
    
    var id: Int {
        return self.hashValue
    }
    
    init(title: String? = nil, items: [SidebarItem]) {
        self.title = title
        self.items = items
    }
    
    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

let sidebarSections: [SidebarSection] = [
    .init(
        items: [.home, .search, .library, .setting]
    )
]

enum SidebarItem: Hashable, Identifiable, CaseIterable {
    case home
    case search
    case library
    case setting
    
    var id: Int {
        return self.hashValue
    }
    
    /// Title of an item
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .search:
            return "Search"
        case .library:
            return "Library"
        case .setting:
            return "Settings"
        }
    }
    
    /// System icon name of an item
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .search:
            return "magnifyingglass"
        case .library:
            return "play.square.stack"
        case .setting:
            return "gearshape"
        }
    }
    
    /// Content that should be presented for the item
    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            // Text("HomeView")
            HomeView()
        case .search:
            Text("SearchView")
//            SearchView()
        case .library:
            Text("LibraryView")
//            LibraryView()
        case .setting:
            Text("SettingsView")
//
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
        hasher.combine(self.iconName)
    }
}

//enum NavigationTarget: Hashable {
//    case artist(Artist)
//    case album(Album)
//    case playlist(Playlist)
//}
