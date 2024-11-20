//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var playerViewModel: PlayerViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 初始化ViewModel
        // 注意：此处假设ContentView已经加载并设置了environmentObject
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            playerViewModel?.play(url)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        playerViewModel?.savePlaylist()
    }
}
