//
//  MelodicStampApp.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import SwiftUI
import CSFBAudioEngine

@main
struct MelodicStampApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.openWindow) var openWindow
    
    @Namespace private var namespace
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 1000, minHeight: 600)
                .edgesIgnoringSafeArea(.top)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        
//        WindowGroup("Mini Player", id: "mini-player") {
//            MiniPlayer(namespace: namespace)
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
let supportedPathExtensions: [String] = {
    var pathExtensions = [String]()
    pathExtensions.append(contentsOf: AudioDecoder.supportedPathExtensions)
    pathExtensions.append(contentsOf: DSDDecoder.supportedPathExtensions)
    return pathExtensions
}()
