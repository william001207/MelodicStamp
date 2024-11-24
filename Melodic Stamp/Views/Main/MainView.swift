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
    
    @State private var metadataEditing: MetadataEditingModel = .init()
    @State private var lastSelection: PlaylistItem?
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
            
            if !selectedTabs.isEmpty {
                HSplitView {
                    ForEach(Array(selectedTabs).sorted { $0.order < $1.order }) { tab in
                        switch tab {
                        case .playlist:
                            PlaylistView(player: player, metadataEditing: metadataEditing)
                                .frame(minWidth: 400)
                                .background {
                                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                                }
                        case .inspector:
                            InspectorView(player: player, metadataEditing: metadataEditing)
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
                .fakeProgressiveBlur(startPoint: .init(x: 0, y: 72 / size.height), endPoint: .init(x: 0, y: 20 / size.height))
            } else {
                EmptyMusicNoteView()
            }
        }
        .toolbar {
            // in order to preserve the titlebar style
            Color.clear
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            self.size = size
        }
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init(SidebarTab.allCases)
    
    MainView(player: .init(), selectedTabs: $selectedTabs)
}
