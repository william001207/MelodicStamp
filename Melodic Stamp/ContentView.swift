//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import Combine
import SwiftUI

struct ContentView: View {
    @Environment(\.appearsActive) private var isActive

    @FocusState private var isFocused

    @Namespace private var namespace

    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var windowManager: WindowManagerModel = .init()
    @State private var fileManager: FileManagerModel = .init()
    @State private var player: PlayerModel = .init()
    @State private var playerKeyboardControl: PlayerKeyboardControlModel = .init()
    @State private var metadataEditor: MetadataEditorModel = .init()
    @State private var lyrics: LyricsModel = .init()

    @State private var isInspectorPresented: Bool = false
    @State private var selectedContentTab: SidebarContentTab = .playlist
    @State private var selectedInspectorTab: SidebarInspectorTab = .commonMetadata

    @State private var minWidth: CGFloat?
    @State private var maxWidth: CGFloat?

    var body: some View {
        Group {
            switch windowManager.style {
            case .main:
                MainView(
                    namespace: namespace,
                    isInspectorPresented: $isInspectorPresented,
                    selectedContentTab: $selectedContentTab,
                    selectedInspectorTab: $selectedInspectorTab
                )
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { _ in
                    floatingWindows.updateTabBarPosition()
                    floatingWindows.updatePlayerPosition()
                }
                .frame(minHeight: 600)
                .ignoresSafeArea()
                .onChange(of: isActive, initial: true) { _, _ in
                    DispatchQueue.main.async {
                        NSApp.mainWindow?.titlebarAppearsTransparent = true
                        NSApp.mainWindow?.titleVisibility = .visible
                    }
                }
            case .miniPlayer:
                MiniPlayer(namespace: namespace)
                    .padding(8)
                    .background {
                        VisualEffectView(
                            material: .hudWindow, blendingMode: .behindWindow
                        )
                    }
                    .padding(.bottom, -32)
                    .ignoresSafeArea()
                    .frame(minWidth: 500, idealWidth: 500)
                    .fixedSize(horizontal: false, vertical: true)
                    .onChange(of: isActive, initial: true) { _, _ in
                        DispatchQueue.main.async {
                            NSApp.mainWindow?.titlebarAppearsTransparent = true
                            NSApp.mainWindow?.titleVisibility = .hidden
                        }
                    }
            }
        }
        .background {
            FileImporters()
                .allowsHitTesting(false)
        }
//        .navigationTitle(title)
        .onAppear {
            floatingWindows.observeFullScreen()
            isFocused = true
        }
        .onChange(of: isActive, initial: true) { _, newValue in
            switch windowManager.style {
            case .main:
                if newValue {
                    initializeFloatingWindows()
                } /*else {
                    destroyFloatingWindows()
                }*/
            case .miniPlayer:
                destroyFloatingWindows()
            }
            isFocused = true
        }
        .onChange(of: windowManager.style, initial: true) { _, newValue in
            switch newValue {
            case .main:
                initializeFloatingWindows()
                minWidth = 960
            case .miniPlayer:
                destroyFloatingWindows()
                maxWidth = 500
            }
            isFocused = true
        }
        .onChange(of: minWidth) { _, newValue in
            guard newValue != nil else { return }
            DispatchQueue.main.async {
                minWidth = nil
            }
        }
        .onChange(of: maxWidth) { _, newValue in
            guard newValue != nil else { return }
            DispatchQueue.main.async {
                maxWidth = nil
            }
        }
        .frame(minWidth: minWidth, maxWidth: maxWidth)
        // Environments
        .environment(floatingWindows)
        .environment(windowManager)
        .environment(fileManager)
        .environment(player)
        .environment(playerKeyboardControl)
        .environment(metadataEditor)
        .environment(lyrics)
        // Focus management
        .focusable()
        .focusEffectDisabled()
        .prefersDefaultFocus(in: namespace)
        .focused($isFocused)
        // Focused values
        .focusedValue(\.windowManager, windowManager)
        .focusedValue(\.fileManager, fileManager)
        .focusedValue(\.player, player)
        .focusedValue(\.playerKeyboardControl, playerKeyboardControl)
        .focusedValue(\.metadataEditor, metadataEditor)
        // Environments
    }

//    private var title: Text {
//        if let current = player.current {
//            let values = current.metadata[extracting: \.title]
//            if let title = values.initial, !title.isEmpty {
//                return Text(title)
//            } else {
//                return Text(current.url.lastPathComponent.dropLast(current.url.pathExtension.count + 1))
//            }
//        } else {
//            return Text("\(Bundle.main.displayName)")
//        }
//    }

    private func initializeFloatingWindows() {
        floatingWindows.addTabBar {
            FloatingTabBarView(
                isInspectorPresented: $isInspectorPresented,
                selectedContentTab: $selectedContentTab,
                selectedInspectorTab: $selectedInspectorTab
            )
            .environment(floatingWindows)
        }
        floatingWindows.addPlayer {
            FloatingPlayerView()
                .environment(floatingWindows)
                .environment(windowManager)
                .environment(player)
                .environment(playerKeyboardControl)
        }
    }

    private func destroyFloatingWindows() {
        floatingWindows.removeTabBar()
        floatingWindows.removePlayer()
    }
}
