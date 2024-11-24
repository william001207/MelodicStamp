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
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(Bundle.main.displayName)") {
                    openWindow(id: "about")
                }
            }
            
            CommandGroup(after: .newItem) {
                Divider()
                
                Menu("Open File") {
                    Button("In Current Playlist") {
                        
                    }
                    .keyboardShortcut("o", modifiers: .command)
                    
                    Button("Replacing Current Playlist") {
                        
                    }
                    .keyboardShortcut("o", modifiers: [.command, .shift])
                    
                    Divider()
                    
                    Button("Form New Playlist") {
                        
                    }
                    .keyboardShortcut("o", modifiers: [.command, .shift, .option])
                }
                
                Menu("Add Files") {
                    Button("To Current Playlist") {
                        
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    
                    Button("Replacing Current Playlist") {
                        
                    }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                    
                    Divider()
                    
                    Button("Form New Playlist") {
                        
                    }
                    .keyboardShortcut("a", modifiers: [.command, .shift, .option])
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
