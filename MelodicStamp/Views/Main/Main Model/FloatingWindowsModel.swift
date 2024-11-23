//
//  FloatingWindowsModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI
import AppKit

@Observable class FloatingWindowsModel {
    private(set) var isTabBarAdded: Bool = false
    private(set) var isPlayerAdded: Bool = false
    
    private let tabBarIdentifier: UUID = .init()
    private let playerIdentifier: UUID = .init()
    
    private var isInFullScreen: Bool = false
    
    var tabBarWindow: NSWindow? {
        NSApp.windows.first(where: { $0.title == tabBarIdentifier.uuidString })
    }
    
    var playerWindow: NSWindow? {
        NSApp.windows.first(where: { $0.title == playerIdentifier.uuidString })
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
        floatingWindow.title = tabBarIdentifier.uuidString
        
        floatingWindow.alphaValue = 0
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        
        DispatchQueue.main.async {
            self.isTabBarAdded = true
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
        floatingWindow.title = playerIdentifier.uuidString
        
        floatingWindow.alphaValue = 0
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        
        DispatchQueue.main.async {
            self.isPlayerAdded = true
            self.updatePlayerPosition(window: floatingWindow, in: applicationWindow)
            floatingWindow.animator().alphaValue = 1
        }
    }
    
    func removeTabBar() {
        guard let tabBarWindow, let applicationWindow = NSApp.mainWindow else { return }
        
        applicationWindow.removeChildWindow(tabBarWindow)
        tabBarWindow.orderOut(nil)
        isTabBarAdded = false
    }
    
    func removePlayer() {
        guard let playerWindow, let applicationWindow = NSApp.mainWindow else { return }
        
        applicationWindow.removeChildWindow(playerWindow)
        playerWindow.orderOut(nil)
        isPlayerAdded = false
    }
    
    func updateTabBarPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let tabBarWindow = window ?? self.tabBarWindow,
            let applicationWindow = mainWindow ?? NSApp.mainWindow
        else { return }
        
        let tabBarFrame = tabBarWindow.frame
        let windowFrame = applicationWindow.frame
        
        let leadingX = windowFrame.origin.x - 16 - 48
        let bottomY = windowFrame.origin.y + (windowFrame.height - tabBarFrame.height) / 2
        
        tabBarWindow.setFrame(
            .init(
                x: isInFullScreen ? max(8, leadingX) : leadingX,
                y: bottomY,
                width: tabBarFrame.width,
                height: tabBarFrame.height
            ),
            display: true
        )
    }
    
    func updatePlayerPosition(window: NSWindow? = nil, in mainWindow: NSWindow? = nil) {
        guard
            let playerWindow = window ?? self.playerWindow,
            let applicationWindow = mainWindow ?? NSApp.mainWindow
        else { return }
        
        let playerFrame = playerWindow.frame
        let windowFrame = applicationWindow.frame
        
        let centerX = windowFrame.origin.x + (windowFrame.width - playerFrame.width) / 2
        let bottomY = windowFrame.origin.y - 32
        
        playerWindow.setFrame(
            .init(
                x: centerX,
                y: isInFullScreen ? max(8, bottomY) : bottomY,
                width: playerFrame.width,
                height: playerFrame.height
            ),
            display: true
        )
    }
}

extension FloatingWindowsModel {
    @objc func windowWillEnterFullScreen(_ notification: Notification) {
        isInFullScreen = true
        hide()
    }
    
    @objc func windowDidEnterFullScreen(_ notification: Notification) {
        show()
    }
    
    @objc func windowWillExitFullScreen(_ notification: Notification) {
        isInFullScreen = false
        hide()
    }
    
    @objc func windowDidExitFullScreen(_ notification: Notification) {
        show()
    }
}
