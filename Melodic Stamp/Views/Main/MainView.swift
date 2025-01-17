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
    @Environment(FileManagerModel.self) private var fileManager
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor

    @Environment(\.appearsActive) private var appearsActive

    @Default(.hidesInspectorWhileInactive) private var hidesInspectorWhileInactive

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
                    .animation(nil, value: metadataEditor.tracks) // Remove strange transitions when selection changes
            }
            .luminareMinHeight(38)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
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
                    .ignoresSafeArea()
                    .morphed()
            case .leaflet:
                LeafletView()
                    .environment(displayLyrics)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .toolbar(removing: .title)
            }
        }
    }

    @ViewBuilder private func inspector() -> some View {
        Group {
            if !hidesInspectorWhileInactive || appearsActive {
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
                case .analytics:
                    InspectorAnalyticsView()
                }
            } else {
                // Stops rendering inspector
                Color.clear
            }
        }
        .environment(inspectorLyrics)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .morphed()
        .ignoresSafeArea()
    }
}

#if DEBUG
    #Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
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
