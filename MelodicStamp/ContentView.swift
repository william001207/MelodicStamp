//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appearsActive) private var isActive
    
    @Namespace private var namespace
    
    @State private var selectedTab: SidebarItem = .home
    
    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var player: PlayerModel = .init()
    @State private var windowStyle: MelodicStampWindowStyle = .main
    
    var body: some View {
        Group {
            switch windowStyle {
            case .main:
                MainView(player: player, selectedTab: $selectedTab)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { newValue in
                        floatingWindows.updateTabBarPosition()
                        floatingWindows.updatePlayerPosition()
                    }
            case .miniPlayer:
                MiniPlayer(player: player, namespace: namespace)
                    .padding(8)
                    .background {
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    }
                    .padding(.bottom, -32)
                    .edgesIgnoringSafeArea(.all)
                    .frame(minWidth: 500, idealWidth: 500)
                    .fixedSize(horizontal: false, vertical: true)
                
                    .environment(\.melodicStampWindowStyle, windowStyle)
                    .environment(\.changeMelodicStampWindowStyle) { windowStyle in
                        self.windowStyle = windowStyle
                    }
            }
        }
        .onChange(of: isActive, initial: true) { oldValue, newValue in
            guard newValue else { return }
            
            switch windowStyle {
            case .main:
                initializeFloatingWindows()
            case .miniPlayer:
                break
            }
        }
        .onChange(of: windowStyle, initial: true) { oldValue, newValue in
            switch newValue {
            case .main:
                initializeFloatingWindows()
            case .miniPlayer:
                floatingWindows.removeTabBar()
                floatingWindows.removePlayer()
            }
        }
    }
    
    private func initializeFloatingWindows() {
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
            .environment(\.changeMelodicStampWindowStyle) { windowStyle in
                self.windowStyle = windowStyle
            }
        }
    }
}
