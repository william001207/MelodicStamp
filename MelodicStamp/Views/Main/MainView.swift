//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct MainView: View {
    @StateObject private var model: FloatingWindowsModel = .init()
    @Environment(\.appearsActive) private var isActive
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            
            model.selectedSidebarItem.content
                .transition(.blurReplace.animation(.smooth(duration: 0.65)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear
            }
        }
        .background {
            GeometryReader {
                let rect = $0.frame(in: .global)
                
                Color.clear
                    .onChange(of: rect) { oldValue, newValue in
                        model.updateTabPosition()
                        model.updatePlayBarPosition()
                    }
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                model.addTabBar()
                model.addPlayer()
            }
        }
    }
}

#Preview {
    MainView()
}
