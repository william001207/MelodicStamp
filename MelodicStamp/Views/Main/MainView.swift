//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct MainView: View {
    @State private var floatingWindowsModel: FloatingWindowsModel = .init()
    @State private var playerModel: PlayerModel = .init()
    
    @Environment(\.appearsActive) private var isActive
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            
            floatingWindowsModel.selectedSidebarItem.content(model: playerModel)
                .transition(.blurReplace.animation(.smooth.speed(2)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear
            }
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            print(1)
            floatingWindowsModel.updateTabBarPosition()
            floatingWindowsModel.updatePlayerPosition()
        }
        .onChange(of: isActive, initial: true) { oldValue, newValue in
            if newValue {
                floatingWindowsModel.addTabBar()
                floatingWindowsModel.addPlayer(model: playerModel)
            }
        }
    }
}

#Preview {
    MainView()
}
