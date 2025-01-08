//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import Combine
import SFBAudioEngine
import SwiftUI

struct ContentView: View {
    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.resetFocus) private var resetFocus

    @FocusState private var isFocused

    @Namespace private var namespace

    @State private var floatingWindows: FloatingWindowsModel = .init()
    @State private var windowManager: WindowManagerModel = .init()
    @State private var fileManager: FileManagerModel = .init()
    @State private var player: PlayerModel = .init(SFBAudioEnginePlayer())
    @State private var playerKeyboardControl: PlayerKeyboardControlModel = .init()
    @State private var metadataEditor: MetadataEditorModel = .init()
    @State private var visualizer: VisualizerModel = .init()

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
        .onChange(of: appearsActive, initial: true) { _, newValue in
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

            guard newValue else { return }
            isFocused = true
            resetFocus(in: namespace)
            player.updateOutputDevices()
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
        .onReceive(player.visualizationDataPublisher) { fftData in
            visualizer.normalizeData(fftData: fftData)
        }
        .frame(minWidth: minWidth, maxWidth: maxWidth)
        // Environments
        .environment(floatingWindows)
        .environment(windowManager)
        .environment(fileManager)
        .environment(player)
        .environment(playerKeyboardControl)
        .environment(metadataEditor)
        .environment(visualizer)
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
        // Avoids multiple instantializations
        let isPlayable = player.isPlayable

        return if isPlayable, let track = player.track {
            MusicTitle.stringifiedTitle(mode: .title, for: track)
        } else {
            Bundle.main.displayName
        }
    }

    private var subtitle: String {
        // Avoids multiple instantializations
        let isPlayable = player.isPlayable

        return if isPlayable, let track = player.track {
            MusicTitle.stringifiedTitle(mode: .artists, for: track)
        } else if !player.isPlaylistEmpty {
            .init(localized: .init(
                "App: (Subtitle) Songs",
                defaultValue: "\(player.playlist.count) Songs",
                comment: "The subtitle displayed when there are songs in the playlist and nothing is playing"
            ))
        } else {
            ""
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
        .onChange(of: appearsActive, initial: true) { _, _ in
            DispatchQueue.main.async {
                NSApp.mainWindow?.titlebarAppearsTransparent = true
                NSApp.mainWindow?.titleVisibility = .visible
            }
        }
    }

    @ViewBuilder private func miniPlayerView() -> some View {
        MiniPlayerView(namespace: namespace)
            .padding(12)
            .padding(.top, 4)
            .background {
                VisualEffectView(
                    material: .hudWindow, blendingMode: .behindWindow
                )
            }
            .padding(.bottom, -32)
            .ignoresSafeArea()
            .frame(minWidth: 500, idealWidth: 500)
            .fixedSize(horizontal: false, vertical: true)
            .onChange(of: appearsActive, initial: true) { _, _ in
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
