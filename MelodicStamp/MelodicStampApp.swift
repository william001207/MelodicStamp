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
    
    @State var model = PlayerModel()
    
    @Environment(\.openWindow) var openWindow
    
    @Namespace private var namespace
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        
        WindowGroup("Mini Player", id: "mini-player") {
            MiniPlayer(namespace: namespace, model: model)
                .padding(8)
                .background {
                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                }
                .padding(.bottom, -32)
                .edgesIgnoringSafeArea(.all)
                .frame(minWidth: 500, idealWidth: 500)
                .fixedSize(horizontal: false, vertical: true)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
