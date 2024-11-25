//
//  MelodicStampApp.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import SwiftUI
import CSFBAudioEngine
import UniformTypeIdentifiers

@main
struct MelodicStampApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(Bundle.main.displayName)") {
                    openWindow(id: "about")
                }
            }
        }
        
        Window("About \(Bundle.main.displayName)", id: "about") {
            AboutView()
        }
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}

// TODO: improve this
let allowedContentTypes: [UTType] = {
    var types = [UTType]()
    types.append(contentsOf: AudioDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.append(contentsOf: DSDDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    return types
}()
