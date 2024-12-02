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
    @State private var lyrics: LyricsModel = .init()

    var body: some View {
        HSplitView {
            Group {
                PlaylistView(player: player, metadataEditor: metadataEditor)
                    .frame(minWidth: 600)
                    .ignoresSafeArea()
                    .morphed()
                    .background {
                        VisualEffectView(material: .menu, blendingMode: .behindWindow)
                    }
                
                ForEach(Array(selectedTabs).sorted(by: { $0.order < $1.order })) { tab in
                    Group {
                        switch tab {
                        case .inspector:
                            InspectorView(player: player, metadataEditor: metadataEditor)
                                .frame(minWidth: 250)
                        case .metadata:
                            MetadataView()
                                .frame(minWidth: 250)
                        case .lyrics:
                            LyricsView(player: player, metadataEditor: metadataEditor, lyrics: lyrics)
                                .frame(minWidth: 350)
                        }
                    }
                    .ignoresSafeArea()
                    .morphed()
                    .background {
                        VisualEffectView(material: tab.material, blendingMode: .behindWindow)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .ignoresSafeArea()
            .inspector(isPresented: .constant(true)) {
                Text("Test")
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()

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

            if isLyricsToolbarPresented {
                ToolbarItemGroup(placement: .confirmationAction) {
                    LyricsToolbar(lyricsType: $lyrics.type)
                        .background(.ultraThinMaterial)
                        .clipShape(.buttonBorder)
                }
            }
        }
    }

    private var isEditorToolbarPresented: Bool {
        let hasEditor = !Set(selectedTabs.map(\.composable))
            .intersection([.metadata])
            .isEmpty
        return hasEditor && !player.isPlaylistEmpty
    }

    private var isLyricsToolbarPresented: Bool {
        let hasEditor = !Set(selectedTabs.map(\.composable))
            .intersection([.lyrics])
            .isEmpty
        return hasEditor && !player.isPlaylistEmpty
    }
}

// #Preview {
//    @Previewable @State var selectedTabs: Set<SidebarTab> = .init(
//        SidebarTab.allCases)
//
//    MainView(fileManager: .init(), player: .init(), selectedTabs: $selectedTabs)
//        .frame(minWidth: 1000, minHeight: 600)
// }
