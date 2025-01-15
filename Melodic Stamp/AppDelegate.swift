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
    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationWillTerminate(_: Notification) {}

    func application(_: NSApplication, open _: [URL]) {}

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        Defaults.canApplicationRestore
    }
}
