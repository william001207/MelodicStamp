//
//  FloatingWindowsModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import SwiftUI

@MainActor @Observable final class FloatingWindowsModel {
    enum WindowStorage {
        case none
        case planned
        case added(NSWindow)
        
        var isEmpty: Bool {
            switch self {
            case .none: true
            default: false
            }
        }
        
        func callAsFunction() -> NSWindow? {
            switch self {
            case .none: nil
            case .planned: nil
            case .added(let window): window
            }
        }
    }
    
    private var isInFullScreen: Bool = false

    var tabBarWindow: WindowStorage = .none
    var playerWindow: WindowStorage = .none

    var isTabBarAdded: Bool { !tabBarWindow.isEmpty }
    var isPlayerAdded: Bool { !playerWindow.isEmpty }

    func observeFullScreen() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillEnterFullScreen),
            name: NSWindow.willEnterFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidEnterFullScreen),
            name: NSWindow.didEnterFullScreenNotification,
            object: NSApp.mainWindow
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillExitFullScreen),
            name: NSWindow.willExitFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidExitFullScreen),
            name: NSWindow.didExitFullScreenNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: NSApp.mainWindow
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: NSApp.mainWindow
        )
    }

    func show() {
        tabBarWindow()?.animator().alphaValue = 1
        playerWindow()?.animator().alphaValue = 1
    }

    func hide() {
        tabBarWindow()?.animator().alphaValue = 0
        playerWindow()?.animator().alphaValue = 0
    }

    func addTabBar(to window: NSWindow? = nil, @ViewBuilder content: @escaping () -> some View) {
        guard !isTabBarAdded else { return }
        tabBarWindow = .planned
        
        guard let applicationWindow = window ?? NSApp.keyWindow else { return }
        
        let floatingWindow = NSWindow()
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        self.tabBarWindow = .added(floatingWindow)
        
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]
        
        floatingWindow.alphaValue = 0
        floatingWindow.animator().alphaValue = 1
        
        DispatchQueue.main.async {
            self.updateTabBarPosition(window: floatingWindow, in: window)
        }
    }

    func addPlayer(to window: NSWindow? = nil, @ViewBuilder content: @escaping () -> some View) {
        guard !isPlayerAdded else { return }
        playerWindow = .planned
        
        guard let applicationWindow = window ?? NSApp.keyWindow else { return }
        
        let floatingWindow = NSWindow()
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        self.playerWindow = .added(floatingWindow)
        
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating
        floatingWindow.collectionBehavior = [.fullScreenNone]
        
        floatingWindow.alphaValue = 0
        floatingWindow.animator().alphaValue = 1
        
        DispatchQueue.main.async {
            self.updatePlayerPosition(window: floatingWindow, in: window)
        }
    }

    func removeTabBar(from window: NSWindow? = nil) {
        guard let tabBarWindow = tabBarWindow(), let applicationWindow = window ?? NSApp.keyWindow else { return }
        
        self.tabBarWindow = .none
        applicationWindow.removeChildWindow(tabBarWindow)
        tabBarWindow.orderOut(nil)
    }

    func removePlayer(from window: NSWindow? = nil) {
        guard let playerWindow = playerWindow(), let applicationWindow = window ?? NSApp.keyWindow else { return }
        
        self.playerWindow = .none
        applicationWindow.removeChildWindow(playerWindow)
        playerWindow.orderOut(nil)
    }

    func updateTabBarPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let tabBarWindow = window ?? tabBarWindow(),
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
            let playerWindow = window ?? playerWindow(),
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

    @objc func windowDidMove(_: Notification) {
        updateTabBarPosition()
        updatePlayerPosition()
    }

    @objc func windowDidResize(_: Notification) {
        updateTabBarPosition()
        updatePlayerPosition()
    }
}
