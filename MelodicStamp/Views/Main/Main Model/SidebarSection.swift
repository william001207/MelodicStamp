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
                .init(systemSymbol: <#T##SFSymbol#>)
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
