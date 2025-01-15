//
//  MelodicStampApp.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import CSFBAudioEngine
import SwiftUI
import UniformTypeIdentifiers

let organizationURL = URL(string: "https://github.com/Cement-Labs")!
let repositoryURL = organizationURL.appending(component: "Melodic-Stamp")

enum WindowID: String {
    case content
    case about
    case settings
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
        WindowGroup(id: "content") {
            ContentView()
                .environment(floatingWindows)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.principal)
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
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.associated)

        Window("Settings", id: WindowID.settings.rawValue) {
            SettingsView()
                .onAppear {
                    isSettingsPresented = true
                }
                .onDisappear {
                    isSettingsPresented = false
                }
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .windowManagerRole(.associated)
    }
}

// TODO: Improve this
let allowedContentTypes: [UTType] = {
    var types = [UTType]()
    types.append(contentsOf: AudioDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.append(contentsOf: DSDDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.append(.ogg)
    return types
}()
