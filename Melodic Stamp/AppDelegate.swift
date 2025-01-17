//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import Defaults
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // Hacky but works
    @Environment(\.openWindow) private var openWindow

    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationWillTerminate(_: Notification) {}

    func application(_: NSApplication, open urls: [URL]) {
        openWindow(id: WindowID.content.rawValue, value: TemporaryStorage(urls: Set(urls)))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        Defaults.canApplicationRestore
    }
}
