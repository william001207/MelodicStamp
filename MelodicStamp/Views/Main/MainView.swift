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
                    ForEach(Array(selectedTabs).sorted { $0.order < $1.order }) { tab in
                        switch tab {
                        case .playlist:
                            PlaylistView(player: player)
                                .frame(minWidth: 200)
                        case .inspector:
                            Color.red
                                .frame(minWidth: 200)
                        case .metadata:
                            Color.blue
                                .frame(minWidth: 200)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
            } else {
                EmptyMusicNoteView()
            }
        }
        .toolbar {
            // in order to preserve the titlebar style
            Color.clear
        }
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init([.playlist])
    
    MainView(player: .init(), selectedTabs: $selectedTabs)
}
