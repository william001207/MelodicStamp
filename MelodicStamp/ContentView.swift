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
    
    @State private var selectedTabs: Set<SidebarTab> = .init([.playlist])
    
    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var player: PlayerModel = .init()
    @State private var windowStyle: MelodicStampWindowStyle = .main
    
    var body: some View {
        Group {
            switch windowStyle {
            case .main:
                MainView(player: player, selectedTabs: $selectedTabs)
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
        .onChange(of: isActive) { oldValue, newValue in
            switch windowStyle {
            case .main:
                if isActive {
                    initializeFloatingWindows()
                } else {
                    destroyFloatingWindows()
                }
            case .miniPlayer:
                destroyFloatingWindows()
            }
        }
        .onChange(of: windowStyle) { oldValue, newValue in
            switch newValue {
            case .main:
                initializeFloatingWindows()
            case .miniPlayer:
                destroyFloatingWindows()
            }
        }
    }
    
    private func initializeFloatingWindows() {
        floatingWindows.addTabBar {
            FloatingTabBarView(
                floatingWindows: floatingWindows,
                sections: [
                    .init(items: [.playlist, .inspector, .metadata])
                ],
                selectedTabs: $selectedTabs
            )
        }
        floatingWindows.addPlayer {
            FloatingPlayerView(
                floatingWindows: floatingWindows,
                player: player
            )
            .environment(\.melodicStampWindowStyle, windowStyle)
            .environment(\.changeMelodicStampWindowStyle) { newValue in
                windowStyle = newValue
            }
        }
    }
    
    private func destroyFloatingWindows() {
        floatingWindows.removeTabBar()
        floatingWindows.removePlayer()
    }
}
