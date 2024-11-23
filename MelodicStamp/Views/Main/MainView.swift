//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.appearsActive) private var isActive
    @Environment(\.melodicStampWindowStyle) private var windowStyle
    @Environment(\.changeMelodicStampWindowStyle) private var changeWindowStyle
    
    @Bindable var player: PlayerModel
    
    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var selectedTab: SidebarItem = .home
    
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
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            floatingWindows.updateTabBarPosition()
            floatingWindows.updatePlayerPosition()
        }
        .onChange(of: isActive, initial: true) { oldValue, newValue in
            switch windowStyle {
            case .main:
                if newValue {
                    floatingWindows.addTabBar {
                        FloatingTabBarView(
                            floatingWindows: floatingWindows,
                            sections: [
                                .init(items: [.home, .search, .library, .setting])
                            ],
                            selectedItem: $selectedTab
                        )
                    }
                    floatingWindows.addPlayer {
                        FloatingPlayerView(
                            floatingWindows: floatingWindows,
                            player: player
                        )
                        .environment(\.melodicStampWindowStyle, windowStyle)
                        .environment(\.changeMelodicStampWindowStyle, changeWindowStyle)
                    }
                }
            default:
                break
            }
        }
        .onDisappear {
            floatingWindows.removeTabBar()
            floatingWindows.removePlayer()
        }
    }
}

#Preview {
    MainView(player: .init())
}
