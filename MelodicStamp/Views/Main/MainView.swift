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
    
    @Binding var selectedTabs: Set<SidebarTab>
    
    var body: some View {
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
            
            if !selectedTabs.isEmpty {
                HSplitView {
                    ForEach(Array(selectedTabs)) { tab in
                        switch tab {
                        default:
                            EmptyView()
                        }
                    }
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
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init([.playlist])
    
    MainView(player: .init(), selectedTabs: $selectedTabs)
}
