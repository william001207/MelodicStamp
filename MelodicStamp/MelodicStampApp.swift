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
        
//        WindowGroup("Mini Player", id: "mini-player") {
//            MiniPlayer(player: .init(), namespace: namespace)
//                .padding(8)
//                .background {
//                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
//                }
//                .padding(.bottom, -32)
//                .edgesIgnoringSafeArea(.all)
//                .frame(minWidth: 500, idealWidth: 500)
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .defaultSize(width: 500, height: 0)
//        .windowResizability(.contentSize)
//        .windowStyle(.hiddenTitleBar)
//        .windowToolbarStyle(.unified)
    }
}

// TODO: improve this
let allowedContentTypes: [UTType] = {
    var types = [UTType]()
    types.append(contentsOf: AudioDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    types.append(contentsOf: DSDDecoder.supportedMIMETypes.compactMap { UTType(mimeType: $0) })
    return types
}()
