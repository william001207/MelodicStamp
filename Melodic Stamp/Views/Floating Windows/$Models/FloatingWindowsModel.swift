//
//  FloatingWindowsModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import SwiftUI

@MainActor @Observable final class FloatingWindowsModel {
    private var isInFullScreen: Bool = false

    var tabBarWindow: NSWindow?
    var playerWindow: NSWindow?

    var isTabBarAdded: Bool { tabBarWindow != nil }
    var isPlayerAdded: Bool { playerWindow != nil }

    private var mainWindowObserver = UUID()

    func observe(_ window: NSWindow? = nil) {
        NotificationCenter.default.removeObserver(mainWindowObserver)

        guard let window else { return }

        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowWillEnterFullScreen),
            name: NSWindow.willEnterFullScreenNotification,
            object: window
        )
        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowDidEnterFullScreen),
            name: NSWindow.didEnterFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowWillExitFullScreen),
            name: NSWindow.willExitFullScreenNotification,
            object: window
        )
        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowDidExitFullScreen),
            name: NSWindow.didExitFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: window
        )
        NotificationCenter.default.addObserver(
            mainWindowObserver,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: window
        )
    }

    func show() {
        tabBarWindow?.animator().alphaValue = 1
        playerWindow?.animator().alphaValue = 1
    }

    func hide() {
        tabBarWindow?.animator().alphaValue = 0
        playerWindow?.animator().alphaValue = 0
    }

    func addTabBar(to mainWindow: NSWindow? = nil, @ViewBuilder content: @escaping () -> some View) {
        guard !isTabBarAdded else { return }
        guard let applicationWindow = mainWindow ?? NSApp.mainWindow else { return }

        let floatingWindow = NSWindow()
        tabBarWindow = floatingWindow

        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]

        floatingWindow.alphaValue = 0
        floatingWindow.animator().alphaValue = 1

        DispatchQueue.main.async {
            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            self.updateTabBarPosition(window: floatingWindow, in: applicationWindow)
        }
    }

    func addPlayer(to mainWindow: NSWindow? = nil, @ViewBuilder content: @escaping () -> some View) {
        guard !isPlayerAdded else { return }
        guard let applicationWindow = mainWindow ?? NSApp.mainWindow else { return }

        let floatingWindow = NSWindow()
        playerWindow = floatingWindow

        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]

        floatingWindow.alphaValue = 0
        floatingWindow.animator().alphaValue = 1

        DispatchQueue.main.async {
            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            self.updatePlayerPosition(window: floatingWindow, in: applicationWindow)
        }
    }

    func removeTabBar(from mainWindow: NSWindow? = nil) {
        guard let tabBarWindow, let applicationWindow = mainWindow ?? NSApp.mainWindow else { return }

        applicationWindow.removeChildWindow(tabBarWindow)
        tabBarWindow.orderOut(nil)
        self.tabBarWindow = nil
    }

    func removePlayer(from mainWindow: NSWindow? = nil) {
        guard let playerWindow, let applicationWindow = mainWindow ?? NSApp.mainWindow else { return }

        applicationWindow.removeChildWindow(playerWindow)
        playerWindow.orderOut(nil)
        self.playerWindow = nil
    }

    func updateTabBarPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let tabBarWindow = window ?? tabBarWindow,
            let applicationWindow = mainWindow ?? NSApp.keyWindow,
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
            let applicationWindow = mainWindow ?? NSApp.keyWindow,
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

    @objc func windowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        updateTabBarPosition(in: window)
        updatePlayerPosition(in: window)
    }

    @objc func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        updateTabBarPosition(in: window)
        updatePlayerPosition(in: window)
    }
}
