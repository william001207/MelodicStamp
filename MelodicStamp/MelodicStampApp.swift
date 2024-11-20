//
//  MelodicStampApp.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import SwiftUI

@main
struct MelodicStampApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var playerViewModel = PlayerViewModel.shared
    
    @Environment(\.openWindow) var openWindow
    
    @Namespace private var animationNamespace
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(playerViewModel)
        
        WindowGroup("Second Window", id: "SecondView") {
            
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                MiniPlayer(namespace: animationNamespace)
            }
            .edgesIgnoringSafeArea(.top)
            .frame(width: 500, height: 75, alignment: .center)
        }
        .environmentObject(playerViewModel)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
