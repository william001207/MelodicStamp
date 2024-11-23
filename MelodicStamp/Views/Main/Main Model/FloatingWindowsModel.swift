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
    
    private var tabBarIdentifier: UUID = .init()
    private var playerIdentifier: UUID = .init()
    
    var tabBarWindow: NSWindow? {
        guard isTabBarAdded else { return nil }
        return NSApp.windows.first(where: { $0.title == tabBarIdentifier.uuidString })
    }
    
    var playerWindow: NSWindow? {
        guard isPlayerAdded else { return nil }
        return NSApp.windows.first(where: { $0.title == playerIdentifier.uuidString })
    }

    func addTabBar(@ViewBuilder content: () -> some View) {
        guard !isTabBarAdded, let applicationWindow = NSApp.mainWindow else { return }
        
        let floatingWindow = NSWindow()
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.title = tabBarIdentifier.uuidString
        
        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        floatingWindow.orderFront(nil)
        isTabBarAdded = true
        
        DispatchQueue.main.async {
            self.updateTabBarPosition()
        }
    }
    
    func addPlayer(@ViewBuilder content: () -> some View) {
        guard !isPlayerAdded, let applicationWindow = NSApp.mainWindow else { return }
        
        let floatingWindow = NSWindow()
        floatingWindow.styleMask = .borderless
        floatingWindow.contentView = NSHostingView(rootView: content())
        floatingWindow.backgroundColor = .clear
        floatingWindow.title = playerIdentifier.uuidString

        applicationWindow.addChildWindow(floatingWindow, ordered: .above)
        floatingWindow.orderFront(nil)
        isPlayerAdded = true
        
        DispatchQueue.main.async {
            self.updatePlayerPosition()
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
    
    func updateTabBarPosition() {
        if let tabBarWindow, let applicationWindow = NSApp.mainWindow {
            let windowFrame = applicationWindow.frame
            let tabBarFrame = tabBarWindow.frame
            
            let centerX = windowFrame.origin.x - 75
            let bottomY = windowFrame.origin.y + (windowFrame.height - tabBarFrame.height) / 2
            
            tabBarWindow.setFrame(
                NSRect(
                    x: centerX,
                    y: bottomY,
                    width: tabBarFrame.width,
                    height: tabBarFrame.height
                ),
                display: true
            )
        }
    }
    
    func updatePlayerPosition() {
        if let playerWindow, let applicationWindow = NSApp.mainWindow {
            let windowFrame = applicationWindow.frame
            let playerFrame = playerWindow.frame

            let centerX = windowFrame.origin.x + (windowFrame.width - playerFrame.width) / 2
            let bottomY = windowFrame.origin.y - 50

            playerWindow.setFrame(
                NSRect(
                    x: centerX,
                    y: bottomY,
                    width: playerFrame.width,
                    height: playerFrame.height
                ),
                display: true
            )
        }
    }
}
