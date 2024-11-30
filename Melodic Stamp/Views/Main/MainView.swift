//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Luminare
import Morphed
import SwiftUI

struct ExcerptAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[.bottom]
    }
    
    static let alignment: VerticalAlignment = .init(ExcerptAlignment.self)
}

struct MainView: View {
    @Environment(\.appearsActive) private var isActive

    @Bindable var fileManager: FileManagerModel
    @Bindable var player: PlayerModel

    @Binding var selectedTabs: Set<SidebarTab>

    @State private var metadataEditor: MetadataEditorModel = .init()

    @State private var size: CGSize = .zero

    var body: some View {
        // use `ZStack` to eliminate safe area animation problems
        ZStack {
            VisualEffectView(
                material: .contentBackground, blendingMode: .behindWindow)

            if !player.isPlaylistEmpty {
                let morphedGradient = LinearGradient(
                    colors: [.white, .black], startPoint: .top,
                    endPoint: .bottom)

                HSplitView {
                    ForEach(Array(selectedTabs).sorted { $0.order < $1.order })
                    { tab in
                        switch tab {
                        case .playlist:
                            PlaylistView(
                                player: player, metadataEditor: metadataEditor
                            )
                            .frame(minWidth: 400)
                            .ignoresSafeArea()

                            .morphed(
                                insets: .init(
                                    bottom: .fixed(length: 64).mirrored),
                                morphedGradient
                            )
                            .ignoresSafeArea()

                            .background {
                                VisualEffectView(
                                    material: .popover,
                                    blendingMode: .behindWindow)
                            }
                        case .inspector:
                            InspectorView(
                                player: player, metadataEditor: metadataEditor
                            )
                            .frame(minWidth: 250)
                            .ignoresSafeArea()

                            .morphed(
                                insets: .init(
                                    bottom: .fixed(length: 64).mirrored),
                                morphedGradient
                            )
                            .ignoresSafeArea()

                            .background {
                                VisualEffectView(
                                    material: .headerView,
                                    blendingMode: .behindWindow)
                            }
                        case .metadata:
                            MetadataView()
                                .frame(minWidth: 250)
                                .ignoresSafeArea()

                                .morphed(
                                    insets: .init(
                                        bottom: .fixed(length: 64).mirrored),
                                    morphedGradient
                                )
                                .ignoresSafeArea()

                                .background {
                                    VisualEffectView(
                                        material: .headerView,
                                        blendingMode: .behindWindow)
                                }
                        }
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                if selectedTabs.isEmpty {
                    EmptyMusicNoteView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack(alignment: ExcerptAlignment.alignment) {
                        ForEach(
                            Array(selectedTabs).sorted { $0.order < $1.order }
                        ) { tab in
                            switch tab {
                            case .playlist:
                                PlaylistExcerpt()
                            case .inspector:
                                InspectorExcerpt()
                            case .metadata:
                                MetadataExcerpt()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity)
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
                    .background(.ultraThinMaterial)
                    .clipShape(.buttonBorder)
            }

            if isEditorToolbarPresented {
                ToolbarItemGroup(placement: .primaryAction) {
                    EditorToolbar(metadataEditor: metadataEditor)
                        .background(.ultraThinMaterial)
                        .clipShape(.buttonBorder)
                }
            }
        }
    }

    private var isEditorToolbarPresented: Bool {
        let hasEditor = !selectedTabs.intersection([.inspector, .metadata])
            .isEmpty
        let hasPlaylist = !player.isPlaylistEmpty
        return hasEditor && hasPlaylist
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init(
        SidebarTab.allCases)

    MainView(fileManager: .init(), player: .init(), selectedTabs: $selectedTabs)
        .frame(minWidth: 1000, minHeight: 600)
}
