//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.appearsActive) private var isActive
    
    @Bindable var player: PlayerModel
    
    @Binding var selectedTab: SidebarItem
    
    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(player: player)
            case .search:
                Text("SearchView")
            case .library:
                Text("LibraryView")
            case .setting:
                Text("SettingsView")
            }
        }
        .transition(.blurReplace.animation(.smooth.speed(2)))
        .background {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .edgesIgnoringSafeArea(.top)
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: SidebarItem = .home
    
    MainView(player: .init(), selectedTab: $selectedTab)
}
