//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import Defaults
import SwiftUI

struct ContentView: View {
    // MARK: - Environments

    @Environment(FloatingWindowsModel.self) private var floatingWindows

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.resetFocus) private var resetFocus

    @FocusState private var isFocused

    @Namespace private var namespace

    @Default(.mainWindowBackgroundStyle) private var mainWindowBackgroundStyle
    @Default(.miniPlayerBackgroundStyle) private var miniPlayerBackgroundStyle
    @Default(.dynamicTitleBar) private var dynamicTitleBar

    // MARK: - Fields

    // MARK: Models

    @State private var windowManager: WindowManagerModel
    @State private var fileManager: FileManagerModel
    @State private var player: PlayerModel
    @State private var playerKeyboardControl: PlayerKeyboardControlModel
    @State private var metadataEditor: MetadataEditorModel
    @State private var audioVisualizer: AudioVisualizerModel
    @State private var gradientVisualizer: GradientVisualizerModel

    // MARK: Sidebar & Inspector

    @State private var isInspectorPresented: Bool = false
    @State private var selectedContentTab: SidebarContentTab = .playlist
    @State private var selectedInspectorTab: SidebarInspectorTab = .commonMetadata

    // MARK: Sizing

    @State private var minWidth: CGFloat?
    @State private var maxWidth: CGFloat?

    // MARK: - Initializers

    init(_ parameters: CreationParameters?) {
        let player = PlayerModel(SFBAudioEnginePlayer())

        self.windowManager = .init(style: parameters?.initialWindowStyle ?? .main)
        self.fileManager = .init(player: player)
        self.player = player
        self.playerKeyboardControl = .init(player: player)
        self.metadataEditor = .init()
        self.audioVisualizer = .init()
        self.gradientVisualizer = .init()

        if let parameters {
            let urls = Array(parameters.urls)
            player.addToPlaylist(urls: urls)

            if parameters.shouldPlay, urls.count == 1, let url = urls.first {
                player.play(url: url)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        CatchWindow { window in
            Group {
                switch windowManager.style {
                case .main:
                    mainView(window)
                case .miniPlayer:
                    miniPlayerView(window)
                }
            }
            .background {
                Group {
                    FileImporters()

                    DelegatedPlayerSceneStorage()
                }
                .allowsHitTesting(false)
            }

            // MARK: Window Styling

            .onAppear {
                isFocused = true
                resetFocus(in: namespace)
            }
            .onChange(of: appearsActive, initial: true) { _, newValue in
                guard newValue else { return }
                isFocused = true
                resetFocus(in: namespace)

                player.updateOutputDevices()
                floatingWindows.observe(window)
                windowManager.observe(window)
            }
            .onChange(of: windowManager.style, initial: true) { _, _ in
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

            // MARK: Updates

            .onChange(of: player.track) { _, newValue in
                Task {
                    if let newValue, let attachedPictures = newValue.metadata[extracting: \.attachedPictures]?.current {
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image
                        await gradientVisualizer.updateDominantColors(from: cover)
                    } else {
                        await gradientVisualizer.updateDominantColors()
                    }
                }
            }
            .onReceive(player.visualizationDataPublisher) { buffer in
                audioVisualizer.updateData(from: buffer)
            }
            .onChange(of: player.isPlaying) { _, newValue in
                guard !newValue else { return }
                audioVisualizer.clearData()
            }
        }
        .frame(minWidth: minWidth, maxWidth: maxWidth)

        // MARK: Environments

        .environment(floatingWindows)
        .environment(windowManager)
        .environment(fileManager)
        .environment(player)
        .environment(playerKeyboardControl)
        .environment(metadataEditor)
        .environment(audioVisualizer)
        .environment(gradientVisualizer)

        // MARK: Focus Management

        .focusable()
        .focusEffectDisabled()
        .prefersDefaultFocus(in: namespace)
        .focused($isFocused)

        // MARK: Focused Values

        .focusedValue(\.windowManager, windowManager)
        .focusedValue(\.fileManager, fileManager)
        .focusedValue(\.player, player)
        .focusedValue(\.playerKeyboardControl, playerKeyboardControl)
        .focusedValue(\.metadataEditor, metadataEditor)

        // MARK: Navigation

        .navigationTitle(title)
        .navigationSubtitle(subtitle)
    }

    private var title: String {
        let fallbackTitle = Bundle.main.displayName

        if player.isPlayable, let track = player.track {
            let musicTitle = MusicTitle.stringifiedTitle(mode: .title, for: track)
            return switch dynamicTitleBar {
            case .never: fallbackTitle
            case .always: musicTitle
            case .whilePlaying: player.isPlaying ? musicTitle : fallbackTitle
            }
        } else {
            return fallbackTitle
        }
    }

    private var subtitle: String {
        let fallbackTitle = if !player.isPlaylistEmpty {
            String(localized: .init(
                "App: (Subtitle) Songs",
                defaultValue: "\(player.playlist.count) Songs",
                comment: "The subtitle displayed when there are songs in the playlist and nothing is playing"
            ))
        } else {
            ""
        }

        if player.isPlayable, let track = player.track {
            let musicSubtitle = MusicTitle.stringifiedTitle(mode: .artists, for: track)
            return switch dynamicTitleBar {
            case .never: fallbackTitle
            case .always: musicSubtitle
            case .whilePlaying: player.isPlaying ? musicSubtitle : fallbackTitle
            }
        } else {
            return fallbackTitle
        }
    }

    // MARK: - Main View

    @ViewBuilder private func mainView(_ window: NSWindow? = nil) -> some View {
        MainView(
            namespace: namespace,
            isInspectorPresented: $isInspectorPresented,
            selectedContentTab: $selectedContentTab,
            selectedInspectorTab: $selectedInspectorTab
        )
        .containerBackground(for: .window) {
            if windowManager.isInFullScreen {
                OpaqueBackgroundView()
            } else {
                switch mainWindowBackgroundStyle {
                case .opaque:
                    OpaqueBackgroundView()
                case .vibrant:
                    VibrantBackgroundView()
                case .ethereal:
                    EtherealBackgroundView()
                }
            }
        }
        .ignoresSafeArea()
        .frame(minHeight: 600)
        .onAppear {
            minWidth = 960
        }
        .onDisappear {
            destroyFloatingWindows()
        }
        .onChange(of: appearsActive, initial: true) { _, newValue in
            if newValue {
                DispatchQueue.main.async {
                    initializeFloatingWindows(to: window)
                }
            } else {
                destroyFloatingWindows(from: window)
            }
        }
    }

    // MARK: - Mini Player View

    @ViewBuilder private func miniPlayerView(_ window: NSWindow? = nil) -> some View {
        MiniPlayerView(namespace: namespace)
            .containerBackground(for: .window) {
                switch miniPlayerBackgroundStyle {
                case .opaque:
                    OpaqueBackgroundView()
                case .vibrant:
                    VibrantBackgroundView()
                case .ethereal:
                    EtherealBackgroundView()
                case .chroma:
                    ChromaBackgroundView()
                        .overlay(.ultraThinMaterial)
                        .environment(player)
                        .environment(audioVisualizer)
                        .environment(gradientVisualizer)
                }
            }
            .padding(12)
            .padding(.top, 4)
            .padding(.bottom, -32)
            .ignoresSafeArea()
            .frame(minWidth: 500, idealWidth: 500)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                maxWidth = 500
                destroyFloatingWindows(from: window)
            }
    }

    // MARK: - Functions

    private func initializeFloatingWindows(to mainWindow: NSWindow? = nil) {
        floatingWindows.addTabBar(to: mainWindow) {
            FloatingTabBarView(
                isInspectorPresented: $isInspectorPresented,
                selectedContentTab: $selectedContentTab,
                selectedInspectorTab: $selectedInspectorTab
            )
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                floatingWindows.updateTabBarPosition(size: newValue, in: mainWindow, animate: true)
            }
            .environment(floatingWindows)
        }
        floatingWindows.addPlayer(to: mainWindow) {
            FloatingPlayerView()
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    floatingWindows.updatePlayerPosition(size: newValue, in: mainWindow, animate: true)
                }
                .environment(floatingWindows)
                .environment(windowManager)
                .environment(fileManager)
                .environment(player)
                .environment(playerKeyboardControl)
                .environment(metadataEditor)
                .environment(audioVisualizer)
                .environment(gradientVisualizer)
        }
    }

    private func destroyFloatingWindows(from mainWindow: NSWindow? = nil) {
        floatingWindows.removeTabBar(from: mainWindow)
        floatingWindows.removePlayer(from: mainWindow)
    }
}
