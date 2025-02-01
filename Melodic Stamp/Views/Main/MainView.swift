//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Defaults
import Luminare
import SwiftUI

struct MainView: View {
    @Environment(WindowManagerModel.self) private var windowManager
    @Environment(FileManagerModel.self) private var fileManager
    @Environment(PlaylistModel.self) private var playlist
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.appearsActive) private var appearsActive

    var namespace: Namespace.ID

    @Binding var isInspectorPresented: Bool
    @Binding var selectedContentTab: SidebarContentTab
    @Binding var selectedInspectorTab: SidebarInspectorTab

    @State private var inspectorLyrics: LyricsModel = .init()
    @State private var displayLyrics: LyricsModel = .init()

    var body: some View {
        content()
            .frame(minWidth: 600, minHeight: 400)
            .inspector(isPresented: $isInspectorPresented) {
                inspector()
                    .ignoresSafeArea()
                    .inspectorColumnWidth(min: 300, ideal: 400, max: 700)
                    .animation(nil, value: playlist.selectedTracks) // Remove strange transitions when selection changes
            }
            .luminareMinHeight(38)
    }

    @ViewBuilder private func content() -> some View {
        Group {
            switch selectedContentTab {
            case .playlist:
                PlaylistView(namespace: namespace)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigation) {
                            FileToolbar()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .safeAreaPadding(.bottom, 94)
                    .toolbarBackgroundVisibility(appearsActive ? .hidden : .automatic, for: .windowToolbar)
                    .morphed(isActive: appearsActive && !windowManager.isInFullScreen)
            case .leaflet:
                LeafletView()
                    .environment(displayLyrics)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .toolbar(removing: .title)
                    .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            }
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
                    .toolbar {
                        if isInspectorPresented {
                            EditorToolbar()

                            LyricsToolbar()
                        }
                    }
            case .library:
                InspectorLibraryView()
                    .toolbar {
                        if isInspectorPresented {
                            LibraryToolbar()
                        }
                    }
            case .analytics:
                InspectorAnalyticsView()
            }
        }
        .environment(inspectorLyrics)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding(.bottom, 94)
        .morphed(isActive: appearsActive && !windowManager.isInFullScreen)
    }
}

#if DEBUG
    #Preview(traits: .modifier(PreviewEnvironments())) {
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
#endif
