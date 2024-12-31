//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import Combine
import SwiftUI
import SFBAudioEngine

struct ContentView: View {
    @Environment(\.appearsActive) private var isActive
    @Environment(\.resetFocus) private var resetFocus

    @FocusState private var isFocused

    @Namespace private var namespace

    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var windowManager: WindowManagerModel = .init()
    @State private var fileManager: FileManagerModel = .init()
    @State private var player: PlayerModel = .init(SFBAudioEnginePlayer())
    @State private var playerKeyboardControl: PlayerKeyboardControlModel = .init()
    @State private var metadataEditor: MetadataEditorModel = .init()

    @State private var isInspectorPresented: Bool = false
    @State private var selectedContentTab: SidebarContentTab = .playlist
    @State private var selectedInspectorTab: SidebarInspectorTab = .commonMetadata

    @State private var minWidth: CGFloat?
    @State private var maxWidth: CGFloat?

    var body: some View {
        Group {
            switch windowManager.style {
            case .main:
                mainView()
                    .presentedWindowStyle(.titleBar)
            case .miniPlayer:
                miniPlayerView()
                    .presentedWindowStyle(.hiddenTitleBar)
            }
        }
        .background {
            FileImporters()
                .allowsHitTesting(false)
        }
        .onAppear {
            floatingWindows.observeFullScreen()
            isFocused = true
            resetFocus(in: namespace)
        }
        .onChange(of: isActive, initial: true) { _, newValue in
            switch windowManager.style {
            case .main:
                if newValue {
                    initializeFloatingWindows()
                } else {
                    destroyFloatingWindows()
                }
            case .miniPlayer:
                destroyFloatingWindows()
            }
            isFocused = true
            resetFocus(in: namespace)
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
            resetFocus(in: namespace)
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
        // Navigation
        .navigationTitle(title)
        .navigationSubtitle(subtitle)
    }

    private var title: String {
        if let current = player.current {
            MusicTitle.stringifiedTitle(mode: .title, for: current)
        } else {
            Bundle.main.displayName
        }
    }

    private var subtitle: String {
        if let current = player.current {
            MusicTitle.stringifiedTitle(mode: .artists, for: current)
        } else if !player.isPlaylistEmpty {
            .init(localized: .init(
                "App: (Subtitle) Songs",
                defaultValue: "\(player.playlist.count) Songs",
                comment: "The subtitle displayed when there are songs in the playlist and nothing is playing"
            ))
        } else {
            .init()
        }
    }

    @ViewBuilder private func mainView() -> some View {
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
    }

    @ViewBuilder private func miniPlayerView() -> some View {
        MiniPlayerView(namespace: namespace)
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

struct ContentEnvironmentsPreviewModifier: PreviewModifier {
    typealias Context = (
        floatingWindows: FloatingWindowsModel,
        windowManager: WindowManagerModel,
        fileManager: FileManagerModel,
        player: PlayerModel,
        playerKeyboardControl: PlayerKeyboardControlModel,
        metadataEditor: MetadataEditorModel
    )
    
    static func makeSharedContext() async throws -> Context {
         (
            FloatingWindowsModel(),
            WindowManagerModel(),
            FileManagerModel(),
            PlayerModel(BlankPlayer()),
            PlayerKeyboardControlModel(),
            MetadataEditorModel()
         )
    }
    
    func body(content: Content, context: Context) -> some View {
        content
            .environment(context.floatingWindows)
            .environment(context.windowManager)
            .environment(context.fileManager)
            .environment(context.player)
            .environment(context.playerKeyboardControl)
            .environment(context.metadataEditor)
    }
}
