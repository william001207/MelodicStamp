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
    @Environment(FileManagerModel.self) private var fileManager
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.appearsActive) private var isActive

    var namespace: Namespace.ID

    @Binding var isInspectorPresented: Bool
    @Binding var selectedContentTab: SidebarContentTab
    @Binding var selectedInspectorTab: SidebarInspectorTab

    @State private var inspectorLyrics: LyricsModel = .init()
    @State private var displayLyrics: LyricsModel = .init()

    var body: some View {
        content()
            .frame(minWidth: 600)
            .inspector(isPresented: $isInspectorPresented) {
                inspector()
                    .ignoresSafeArea()
                    .inspectorColumnWidth(min: 300, ideal: 400, max: 700)
                    .animation(nil, value: metadataEditor.items) // Remove strange transitions when selection changes
            }
            .ignoresSafeArea()
            .luminareMinHeight(38)
            .toolbar {
                // At least to preserve the titlebar style
                Color.clear
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    FileToolbar()
                }
            }
    }

    @ViewBuilder private func content() -> some View {
        switch selectedContentTab {
        case .playlist:
            PlaylistView(namespace: namespace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .morphed()
                .background {
                    VisualEffectView(material: .headerView, blendingMode: .behindWindow)
                }
                .ignoresSafeArea()
        case .leaflet:
            LeafletView()
                .environment(displayLyrics)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private func inspector() -> some View {
        Group {
            switch selectedInspectorTab {
            case .commonMetadata:
                InspectorCommonMetadataView()
                    .toolbar {
                        if isInspectorPresented {
                            EditorToolbar()
                        }
                    }
            case .advancedMetadata:
                InspectorAdvancedMetadataView()
                    .toolbar {
                        if isInspectorPresented {
                            EditorToolbar()
                        }
                    }
            case .lyrics:
                InspectorLyricsView()
            case .analytics:
                InspectorAnalyticsView()
            }
        }
        .environment(inspectorLyrics)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .morphed()
        .ignoresSafeArea()
    }
}

#Preview(traits: .modifier(ContentEnvironmentsPreviewModifier())) {
    @Previewable @Namespace var namespace
    @Previewable @State var isInspectorPresented = true
    @Previewable @State var selectedContentTab: SidebarContentTab = .playlist
    @Previewable @State var selectedInspectorTab: SidebarInspectorTab = .commonMetadata

    MainView(
        namespace: namespace,
        isInspectorPresented: $isInspectorPresented,
        selectedContentTab: $selectedContentTab,
        selectedInspectorTab: $selectedInspectorTab
    )
}
