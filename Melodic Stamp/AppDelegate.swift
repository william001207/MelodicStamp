//
//  AppDelegate.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import Defaults
import SwiftUI

extension AppDelegate: TypeNameReflectable {}

class AppDelegate: NSObject, NSApplicationDelegate {
    // Hacky but works
    @Environment(\.openWindow) private var openWindow

    private var suspendedWindows: Set<NSWindow> = []

    func resumeWindowSuspension() {
        logger.info("Resumed window suspension")
        suspendedWindows.removeAll()
        NSApp.reply(toApplicationShouldTerminate: false)
    }

    func suspend(window: NSWindow?) {
        if let window {
            suspendedWindows.insert(window)
            logger.info("Suspended \(window)")
        }
    }

    func destroy(window: NSWindow?) {
        if let window, suspendedWindows.contains(window) {
            suspendedWindows.remove(window)
            logger.info("Destroyed \(window)")
        }

        if suspendedWindows.isEmpty {
            logger.info("Terminated application because no window is suspended anymore")
            NSApp.reply(toApplicationShouldTerminate: true)
        }
    }
}

extension AppDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationWillTerminate(_: Notification) {}

    func application(_: NSApplication, open urls: [URL]) {
        openWindow(id: WindowID.content(), value: CreationParameters(playlist: .referenced(urls)))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if sender.windows.isEmpty {
            return .terminateNow
        } else {
            // Allows each window to delegate its closing
            sender.windows.forEach { $0.performClose(nil) }
            return .terminateLater
        }
    }
}
