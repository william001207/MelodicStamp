//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    @Environment(\.dismissWindow) private var dismissWindow

    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        closeAuxiliaryWindows()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func application(_: NSApplication, open _: [URL]) {}

    func applicationWillTerminate(_: Notification) {
        closeAuxiliaryWindows()
    }
}

extension AppDelegate {
    private func closeAuxiliaryWindows() {
        // This emits warnings, but it's OK to ignore
        dismissWindow(id: WindowID.about.rawValue)
        dismissWindow(id: WindowID.settings.rawValue)
    }
}
