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

    private var suspendedWindows: Set<NSWindow> = []

    func resumeWindowSuspension() {
        print("Resume")
        suspendedWindows.removeAll()
        NSApp.reply(toApplicationShouldTerminate: false)
    }

    func suspend(window: NSWindow?) {
        if let window {
            suspendedWindows.insert(window)
            print("Suspended \(window)")
        }
    }

    func destroy(window: NSWindow?) {
        if let window, suspendedWindows.contains(window) {
            suspendedWindows.remove(window)
            print("Destroyed \(window)")

            if suspendedWindows.isEmpty {
                print("Terminated")
                NSApp.reply(toApplicationShouldTerminate: true)
            }
        }
    }
}

extension AppDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationWillTerminate(_: Notification) {}

    func application(_: NSApplication, open urls: [URL]) {
        openWindow(id: WindowID.content.rawValue, value: CreationParameters(urls: Set(urls)))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        Defaults.canApplicationRestore
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard sender.windows.isEmpty else {
            sender.windows.forEach { $0.performClose(nil) }
            return .terminateLater
        }

        return .terminateNow
    }
}
