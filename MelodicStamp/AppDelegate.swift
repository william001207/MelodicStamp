//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var model: PlayerModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        playerViewModel.setupRemoteCommandCenter()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            model?.play(url)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        model?.savePlaylist()
    }
}
