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
    
    @State private var selection: Set<PlaylistItem> = .init()
    @State private var lastSelection: PlaylistItem?
    
    var body: some View {
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
            
            if !selectedTabs.isEmpty {
                HSplitView {
                    ForEach(Array(selectedTabs).sorted { $0.order < $1.order }) { tab in
                        switch tab {
                        case .playlist:
                            PlaylistView(player: player, selection: $selection, lastSelection: $lastSelection)
                                .frame(minWidth: 400)
                                .background {
                                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                                }
                        case .inspector:
                            InspectorView(player: player, selection: $selection, lastSelection: $lastSelection)
                                .frame(minWidth: 250)
                                .background {
                                    VisualEffectView(material: .headerView, blendingMode: .behindWindow)
                                }
                        case .metadata:
                            MetadataView()
                                .frame(minWidth: 250)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
