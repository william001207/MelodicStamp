//
//  FloatingWindowsModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import SwiftUI

@Observable class FloatingWindowsModel {
    private var isInFullScreen: Bool = false

    var tabBarWindow: NSWindow?
    var playerWindow: NSWindow?

    var isTabBarAdded: Bool {
        tabBarWindow != nil
    }

    var isPlayerAdded: Bool {
        playerWindow != nil
    }

    func observeFullScreen() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillEnterFullScreen(_:)),
            name: NSWindow.willEnterFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidEnterFullScreen(_:)),
            name: NSWindow.didEnterFullScreenNotification,
            object: NSApp.mainWindow
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillExitFullScreen(_:)),
            name: NSWindow.willExitFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidExitFullScreen(_:)),
            name: NSWindow.didExitFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: NSApp.mainWindow
        )
    }

    func hide() {
        tabBarWindow?.animator().alphaValue = 0
        playerWindow?.animator().alphaValue = 0
    }

    func show() {
        tabBarWindow?.animator().alphaValue = 1
        playerWindow?.animator().alphaValue = 1
    }

    func addTabBar(@ViewBuilder content: () -> some View) {
        guard !isTabBarAdded, let applicationWindow = NSApp.mainWindow else { return }

        let floatingWindow = NSWindow()
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]

        floatingWindow.alphaValue = 0
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)

        DispatchQueue.main.async {
            self.tabBarWindow = floatingWindow
            self.updateTabBarPosition(window: floatingWindow, in: applicationWindow)
            floatingWindow.animator().alphaValue = 1
        }
    }

    func addPlayer(@ViewBuilder content: () -> some View) {
        guard !isPlayerAdded, let applicationWindow = NSApp.mainWindow else { return }

        let floatingWindow = NSWindow()
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]

        floatingWindow.alphaValue = 0
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)

        DispatchQueue.main.async {
            self.playerWindow = floatingWindow
            self.updatePlayerPosition(window: floatingWindow, in: applicationWindow)
            floatingWindow.animator().alphaValue = 1
        }
    }

    func removeTabBar() {
        guard let tabBarWindow, let applicationWindow = NSApp.mainWindow else { return }

        applicationWindow.removeChildWindow(tabBarWindow)
        tabBarWindow.orderOut(nil)
        self.tabBarWindow = nil
    }

    func removePlayer() {
        guard let playerWindow, let applicationWindow = NSApp.mainWindow else { return }

        applicationWindow.removeChildWindow(playerWindow)
        playerWindow.orderOut(nil)
        self.playerWindow = nil
    }

    func updateTabBarPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let tabBarWindow = window ?? tabBarWindow,
            let applicationWindow = mainWindow ?? NSApp.mainWindow,
            let screen = NSScreen.main
        else { return }

        let tabBarFrame = tabBarWindow.frame
        let windowFrame = applicationWindow.frame
        let screenFrame = screen.frame

        let leadingX = windowFrame.origin.x - 16 - 48
        let bottomY = windowFrame.origin.y + (windowFrame.height - tabBarFrame.height) / 2

        tabBarWindow.setFrame(
            .init(
                x: max(screenFrame.minX + 8, leadingX),
                y: bottomY,
                width: tabBarFrame.width,
                height: tabBarFrame.height
            ),
            display: true
        )
    }

    func updatePlayerPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let playerWindow = window ?? playerWindow,
            let applicationWindow = mainWindow ?? NSApp.mainWindow,
            let screen = NSScreen.main
        else { return }

        let playerFrame = playerWindow.frame
        let windowFrame = applicationWindow.frame
        let screenFrame = screen.frame

        let centerX = windowFrame.origin.x + (windowFrame.width - playerFrame.width) / 2
        let bottomY = windowFrame.origin.y - 32

        playerWindow.setFrame(
            .init(
                x: centerX,
                y: max(screenFrame.minY + 8, bottomY),
                width: playerFrame.width,
                height: playerFrame.height
            ),
            display: true
        )
    }
}

extension FloatingWindowsModel {
    @objc func windowWillEnterFullScreen(_: Notification) {
        isInFullScreen = true
        hide()
    }

    @objc func windowDidEnterFullScreen(_: Notification) {
        show()
    }

    @objc func windowWillExitFullScreen(_: Notification) {
        isInFullScreen = false
        hide()
    }

    @objc func windowDidExitFullScreen(_: Notification) {
        show()
    }

    @objc func windowDidMove(_: Notification) {
        updateTabBarPosition()
        updatePlayerPosition()
    }

    @objc func windowDidResize(_: Notification) {
        updateTabBarPosition()
        updatePlayerPosition()
    }
}
