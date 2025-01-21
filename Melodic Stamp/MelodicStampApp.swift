//
//  MelodicStampApp.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import CSFBAudioEngine
import SwiftUI
import UniformTypeIdentifiers

enum WindowID: String, Equatable, Hashable, CaseIterable, Identifiable, Codable {
    case content
    case about
    case settings

    var id: Self { self }
}

@main
struct MelodicStampApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @FocusedValue(\.windowManager) private var windowManager

    @State private var isAboutPresented: Bool = false
    @State private var isSettingsPresented: Bool = false

    @State private var floatingWindows: FloatingWindowsModel = .init()

    var body: some Scene {
        WindowGroup(id: WindowID.content.rawValue, for: CreationParameters.self) { $parameters in
            ContentView(parameters)
                .environment(floatingWindows)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.principal)
        .handlesExternalEvents(matching: []) // Crucial for handling custom external events in `AppDelegate`
        .commands {
            InspectorCommands()

            CommandGroup(replacing: .appInfo) {
                Button("About \(Bundle.main.displayName)") {
                    if isAboutPresented {
                        dismissWindow(id: WindowID.about.rawValue)
                    } else {
                        openWindow(id: WindowID.about.rawValue)
                    }
                }

                Button("Settings…") {
                    if isSettingsPresented {
                        dismissWindow(id: WindowID.settings.rawValue)
                    } else {
                        openWindow(id: WindowID.settings.rawValue)
                    }
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            FileCommands()

            EditingCommands()

            PlayerCommands()

            PlaylistCommands()

            WindowCommands()
        }

        Window("About \(Bundle.main.displayName)", id: WindowID.about.rawValue) {
            AboutView()
                .onAppear {
                    isAboutPresented = true
                }
                .onDisappear {
                    isAboutPresented = false
                }
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.associated)
        .handlesExternalEvents(matching: []) // Crucial for handling custom external events in `AppDelegate`

        Window("Settings", id: WindowID.settings.rawValue) {
            SettingsView()
                .onAppear {
                    isSettingsPresented = true
                }
                .onDisappear {
                    isSettingsPresented = false
                }
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.associated)
        .handlesExternalEvents(matching: []) // Crucial for handling custom external events in `AppDelegate`
    }
}

// TODO: Improve this
let allowedContentTypes: Set<UTType> = {
    var types: Set<UTType> = []
    types.formUnion(AudioDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.formUnion(DSDDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.formUnion([.ogg])
    return types
}()
