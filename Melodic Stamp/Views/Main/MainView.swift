//
//  MainView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Luminare
import Morphed
import SwiftUI

extension View {
    @ViewBuilder fileprivate func morphed() -> some View {
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

    @Binding var isInspectorPresented: Bool
    @Binding var selectedTab: SidebarTab

    @State private var metadataEditor: MetadataEditorModel = .init()
    @State private var lyrics: LyricsModel = .init()

    var body: some View {
        playlist()
            .inspector(isPresented: $isInspectorPresented) {
                inspector()
                    .ignoresSafeArea()
            }
            .inspectorColumnWidth(min: 250, ideal: 350, max: 500)
            .ignoresSafeArea()

            .toolbar {
                // at least to preserve the titlebar style
                Color.clear
            }
    }

    @ViewBuilder private func playlist() -> some View {
        PlaylistView(player: player, metadataEditor: metadataEditor)
            .ignoresSafeArea()

            .morphed()
            .background {
                VisualEffectView(material: .menu, blendingMode: .behindWindow)
            }
            .ignoresSafeArea()
    }

    @ViewBuilder private func inspector() -> some View {
        Group {
            switch selectedTab {
            case .inspector:
                InspectorView(player: player, metadataEditor: metadataEditor)
            case .metadata:
                MetadataView()
            case .lyrics:
                LyricsView(
                    player: player, metadataEditor: metadataEditor,
                    lyrics: lyrics)
            }
        }
        .ignoresSafeArea()

        .morphed()
        .background {
            VisualEffectView(
                material: selectedTab.material, blendingMode: .behindWindow)
        }
        .ignoresSafeArea()
    }
}

// #Preview {
//    @Previewable @State var isInspectorPresented: Bool = false
//    @Previewable @State var selectedTab: SidebarTab = .inspector
//
//    MainView(fileManager: .init(), player: .init(), isInspectorPresented: $isInspectorPresented, selectedTab: $selectedTab)
//        .frame(minWidth: 1000, minHeight: 600)
// }
