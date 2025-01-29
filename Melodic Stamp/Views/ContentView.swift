//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import Defaults
import Luminare
import SwiftUI

extension ContentView: TypeNameReflectable {}

struct ContentView: View {
    struct Sizer: Equatable, Hashable {
        var minWidth: CGFloat?
        var maxWidth: CGFloat?
        var minHeight: CGFloat?
        var maxHeight: CGFloat?

        mutating func with(windowStyle: MelodicStampWindowStyle) {
            switch windowStyle {
            case .main:
                minWidth = 960
                maxWidth = nil
                minHeight = 550
                maxHeight = 550
            case .miniPlayer:
                minWidth = nil
                maxWidth = 500
                minHeight = nil
                maxHeight = nil
            }
        }

        mutating func reset() {
            minWidth = nil
            maxWidth = nil
            minHeight = nil
            maxHeight = nil
        }
    }

    // MARK: - Environments

    @Environment(FloatingWindowsModel.self) private var floatingWindows

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.resetFocus) private var resetFocus
    @Environment(\.dismissWindow) private var dismissWindow

    @FocusState private var isFocused

    @Namespace private var namespace

    @Default(.mainWindowBackgroundStyle) private var mainWindowBackgroundStyle
    @Default(.miniPlayerBackgroundStyle) private var miniPlayerBackgroundStyle
    @Default(.dynamicTitleBar) private var dynamicTitleBar

    // MARK: - Fields

    private let parameters: CreationParameters

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

    // MARK: Window

    @State private var sizer: Sizer = .init()
    @State private var isUnsavedChangesPresented: Bool = false
    @State private var floatingWindowsInitializationDispatch: DispatchWorkItem?

    // MARK: - Initializers

    init(_ parameters: CreationParameters) {
        self.parameters = parameters
        Self.logger.info("Unwrapped parameters to \("\(parameters)")")

        let player = PlayerModel(SFBAudioEnginePlayer(), bindingTo: parameters.id)

        self.windowManager = WindowManagerModel(style: parameters.initialWindowStyle)
        self.fileManager = FileManagerModel(player: player)
        self.player = player
        self.playerKeyboardControl = PlayerKeyboardControlModel(player: player)
        self.metadataEditor = MetadataEditorModel(player: player)
        self.audioVisualizer = AudioVisualizerModel()
        self.gradientVisualizer = GradientVisualizerModel()
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
            .onAppear {
                initialize()
            }
            .dropDestination(for: Track.self) { tracks, _ in
                player.addToPlaylist(tracks.map(\.url))
                return true
            }
            .background {
                Group {
                    FileImporters()

//                    DelegatedPlayerSceneStorage()
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
            .onChange(of: windowManager.style, initial: true) { _, newValue in
                isFocused = true
                resetFocus(in: namespace)
                sizer.with(windowStyle: newValue)

                DispatchQueue.main.async {
                    sizer.reset()
                }
            }

            // MARK: Updates

            .onChange(of: player.currentTrack) { _, newValue in
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

            // MARK: Unsaved Changes

            .modifier(UnsavedChangesModifier(isPresented: $isUnsavedChangesPresented, window: window))
        }
        .frame(minWidth: sizer.minWidth, maxWidth: sizer.maxWidth, minHeight: sizer.minHeight, maxHeight: sizer.maxHeight)

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
        let fallbackTitle = Bundle.main[localized: .displayName]

        if player.isPlayable, let track = player.currentTrack {
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

        if player.isPlayable, let track = player.currentTrack {
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
        .onDisappear {
            destroyFloatingWindows()
        }
        .onChange(of: appearsActive, initial: true) { _, newValue in
            if newValue {
                initializeFloatingWindows(to: window)
            } else {
                destroyFloatingWindows(from: window)
            }
        }
        .onChange(of: appearsActive, initial: true) { _, newValue in
            guard newValue else { return }

            Task.detached {
                await player.library.refresh()
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
                destroyFloatingWindows(from: window)
            }
    }

    // MARK: - Functions

    private func initialize() {
        if !windowManager.isInitialized {
            windowManager.isInitialized = true

            Task.detached {
                switch parameters.playlist {
                case let .referenced(urls):
                    await player.addToPlaylist(urls)

                    logger.info("Created window from referenced URLs: \(urls)")
                case let .canonical(id):
                    await player.library.saveOrLoadPlaylist()

                    logger.info("Created window with canonical ID: \(id)")
                }

                if parameters.shouldPlay, let firstTrack = await player.playlist.first {
                    await player.play(firstTrack.url)
                }
            }
        }
    }

    private func initializeFloatingWindows(to mainWindow: NSWindow? = nil) {
        floatingWindowsInitializationDispatch?.cancel()
        let dispatch = DispatchWorkItem {
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
        floatingWindowsInitializationDispatch = dispatch
        DispatchQueue.main.async(execute: dispatch)
    }

    private func destroyFloatingWindows(from mainWindow: NSWindow? = nil) {
        floatingWindowsInitializationDispatch?.cancel()
        floatingWindows.removeTabBar(from: mainWindow)
        floatingWindows.removePlayer(from: mainWindow)
    }
}
