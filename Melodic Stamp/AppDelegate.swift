//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
//        playerViewModel.setupRemoteCommandCenter()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func application(_: NSApplication, open urls: [URL]) {
        if let url = urls.first {
//            model?.play(url)
        }
    }

    func applicationWillTerminate(_: Notification) {}
}
