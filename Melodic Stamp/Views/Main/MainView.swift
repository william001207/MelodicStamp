//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Luminare
import Morphed
import SwiftUI

private extension View {
    @ViewBuilder func morphed() -> some View {
        morphed(
            insets: .init(bottom: .fixed(length: 64).mirrored),
            LinearGradient(
                colors: [.white, .black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
        .morphed(
            insets: .init(top: .fixed(length: 94).mirrored),
            LinearGradient(
                colors: [.white, .black],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .ignoresSafeArea()
    }
}

struct MainView: View {
    @Environment(\.appearsActive) private var isActive

    @Bindable var fileManager: FileManagerModel
    @Bindable var player: PlayerModel
    
    var namespace: Namespace.ID

    @Binding var isInspectorPresented: Bool
    @Binding var selectedContentTab: SidebarContentTab
    @Binding var selectedInspectorTab: SidebarInspectorTab

    @State private var metadataEditor: MetadataEditorModel = .init()
    @State private var lyrics: LyricsModel = .init()

    var body: some View {
        playlist()
            .frame(minWidth: 500)
            .inspector(isPresented: $isInspectorPresented) {
                inspector()
                    .ignoresSafeArea()
                    .inspectorColumnWidth(min: 300, ideal: 400, max: 650)
            }
            .ignoresSafeArea()
            .luminareMinHeight(38)
            .toolbar {
                // at least to preserve the titlebar style
                Color.clear
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    FileToolbar(player: player, fileManager: fileManager)
                }
                
#if DEBUG
                ToolbarItemGroup(placement: .cancellationAction) {
                    DebugToolbar()
                }
#endif
            }
    }

    @ViewBuilder private func playlist() -> some View {
        PlaylistView(player: player, metadataEditor: metadataEditor, namespace: namespace)
            .luminareAnimation(.default.speed(5))
            .ignoresSafeArea()
            .morphed()
            .background {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            }
            .ignoresSafeArea()
    }

    @ViewBuilder private func inspector() -> some View {
        Group {
            switch selectedInspectorTab {
            case .commonMetadata:
                InspectorView(metadataEditor: metadataEditor)
                    .toolbar {
                        if isInspectorPresented {
                            EditorToolbar(metadataEditor: metadataEditor)
                        }
                    }
            case .advancedMetadata:
                MetadataView(metadataEditor: metadataEditor)
                    .toolbar {
                        if isInspectorPresented {
                            EditorToolbar(metadataEditor: metadataEditor)
                        }
                    }
            case .lyrics:
                LyricsView(
                    player: player, metadataEditor: metadataEditor,
                    lyrics: lyrics
                )
                .toolbar {
                    if isInspectorPresented {
                        LyricsToolbar(lyricsType: $lyrics.type)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .morphed()
        .ignoresSafeArea()
    }
}
