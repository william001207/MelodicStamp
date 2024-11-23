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
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
            
            Group {
                switch selectedTab {
                case .home:
                    HomeView(player: player)
                }
            }
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
