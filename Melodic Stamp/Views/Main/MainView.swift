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
    
    @State private var metadataEditor: MetadataEditorModel = .init()
    @State private var fileManager: FileManagerModel = .init()
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
            
            fileImporters()
                .allowsHitTesting(false)
            
            if !player.isPlaylistEmpty {
                HSplitView {
                    ForEach(Array(selectedTabs).sorted { $0.order < $1.order }) { tab in
                        switch tab {
                        case .playlist:
                            PlaylistView(player: player, metadataEditor: metadataEditor)
                                .frame(minWidth: 400)
                                .background {
                                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                                }
                        case .inspector:
                            InspectorView(player: player, metadataEditor: metadataEditor)
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
                    .ignoresSafeArea()
                }
                .fakeProgressiveBlur(startPoint: .init(x: 0, y: 72 / size.height), endPoint: .init(x: 0, y: 20 / size.height))
            } else {
                if selectedTabs.isEmpty {
                    EmptyMusicNoteView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack {
                        ForEach(Array(selectedTabs).sorted { $0.order < $1.order }) { tab in
                            switch tab {
                            case .playlist:
                                PlaylistExcerpt()
                            case .inspector:
                                InspectorExcerpt()
                            case .metadata:
                                MetadataExcerpt()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(24)
                    .padding(.bottom, 16)
                }
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            self.size = size
        }
        
        // toolbar
        .toolbar {
            // at least to preserve the titlebar style
            Color.clear
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                FileToolbar(player: player, fileManager: fileManager)
            }
            
            if isEditorToolbarPresented {
                ToolbarItemGroup(placement: .primaryAction) {
                    EditorToolbar(metadataEditor: metadataEditor)
                }
            }
        }
    }
    
    private var isEditorToolbarPresented: Bool {
        let hasEditor = !selectedTabs.intersection([.inspector, .metadata]).isEmpty
        let hasPlaylist = !player.isPlaylistEmpty
        return hasEditor && hasPlaylist
    }
    
    @ViewBuilder private func fileImporters() -> some View {
        Color.clear
            .fileImporter(
                isPresented: $fileManager.isFileOpenerPresented,
                allowedContentTypes: allowedContentTypes
            ) { result in
                switch result {
                case .success(let url):
                    switch fileManager.fileOpenerPresentationStyle {
                    case .inCurrentPlaylist:
                        player.play(url: url)
                    case .replacingCurrentPlaylist:
                        break
                    case .formNewPlaylist:
                        break
                    }
                case .failure:
                    break
                }
            }
        
        Color.clear
            .fileImporter(
                isPresented: $fileManager.isFileAdderPresented,
                allowedContentTypes: allowedContentTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    switch fileManager.fileAdderPresentationStyle {
                    case .toCurrentPlaylist:
                        player.addToPlaylist(urls: urls)
                    case .replacingCurrentPlaylist:
                        break
                    case .formNewPlaylist:
                        break
                    }
                case .failure:
                    break
                }
            }
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init(SidebarTab.allCases)
    
    MainView(player: .init(), selectedTabs: $selectedTabs)
        .frame(minWidth: 1000, minHeight: 600)
}
