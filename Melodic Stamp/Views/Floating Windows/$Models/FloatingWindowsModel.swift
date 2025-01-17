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

    var isHidden: Bool = false {
        didSet {
            if isHidden {
                hide()
                isVisibilityDelegated = true
            } else {
                show()
                isVisibilityDelegated = false
            }
        }
    }

    private var isVisibilityDelegated: Bool = false

    var tabBarWindow: NSWindow?
    var playerWindow: NSWindow?

    var isTabBarAdded: Bool { tabBarWindow != nil }
    var isPlayerAdded: Bool { playerWindow != nil }

    func observe(_ window: NSWindow? = nil) {
        NotificationCenter.default.removeObserver(self)
        guard let window else { return }

        isInFullScreen = window.isInFullScreen

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillEnterFullScreen),
            name: NSWindow.willEnterFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidEnterFullScreen),
            name: NSWindow.didEnterFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillExitFullScreen),
            name: NSWindow.willExitFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidExitFullScreen),
            name: NSWindow.didExitFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: window
        )
    }

    private func show() {
        tabBarWindow?.animator().alphaValue = 1
        playerWindow?.animator().alphaValue = 1
    }

    private func hide() {
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
            self.isHidden = false
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
            self.isHidden = false
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

    func updateTabBarPosition(window: NSWindow? = nil, size: CGSize? = nil, in mainWindow: NSWindow? = nil, animate: Bool = false) {
        guard
            let tabBarWindow = window ?? tabBarWindow,
            let applicationWindow = mainWindow ?? NSApp.keyWindow,
            let screen = NSScreen.main
        else { return }

        let tabBarFrame = tabBarWindow.frame
        let tabBarSize = size ?? tabBarFrame.size
        let windowFrame = applicationWindow.frame
        let screenFrame = screen.frame

        let leadingX = windowFrame.origin.x - 16 - 48
        let bottomY = windowFrame.origin.y + (windowFrame.height - tabBarSize.height) / 2

        tabBarWindow.setFrame(
            .init(
                x: max(screenFrame.minX + 8, leadingX),
                y: bottomY,
                width: tabBarSize.width,
                height: tabBarSize.height
            ),
            display: true,
            animate: animate
        )
    }

    func updatePlayerPosition(window: NSWindow? = nil, size: CGSize? = nil, in mainWindow: NSWindow? = nil, animate: Bool = false) {
        guard
            let playerWindow = window ?? playerWindow,
            let applicationWindow = mainWindow ?? NSApp.keyWindow,
            let screen = NSScreen.main
        else { return }

        let playerFrame = playerWindow.frame
        let playerSize = size ?? playerFrame.size
        let windowFrame = applicationWindow.frame
        let screenFrame = screen.frame

        let centerX = windowFrame.origin.x + (windowFrame.width - playerSize.width) / 2
        let bottomY = windowFrame.origin.y - 32

        playerWindow.setFrame(
            .init(
                x: centerX,
                y: max(screenFrame.minY + 8, bottomY),
                width: playerSize.width,
                height: playerSize.height
            ),
            display: true,
            animate: animate
        )
    }
}

extension FloatingWindowsModel {
    @objc func windowWillEnterFullScreen(_: Notification) {
        isInFullScreen = true

        guard !isVisibilityDelegated else { return }
        hide()
    }

    @objc func windowDidEnterFullScreen(_: Notification) {
        guard !isVisibilityDelegated else { return }
        show()
    }

    @objc func windowWillExitFullScreen(_: Notification) {
        isInFullScreen = false

        guard !isVisibilityDelegated else { return }
        hide()
    }

    @objc func windowDidExitFullScreen(_: Notification) {
        guard !isVisibilityDelegated else { return }
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
