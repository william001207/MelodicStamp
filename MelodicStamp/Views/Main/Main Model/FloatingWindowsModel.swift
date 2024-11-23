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

    func addTabBar(@ViewBuilder content: () -> some View) {
        guard !isTabBarAdded else { return }
        
        if let applicationWindow = NSApp.mainWindow {
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = NSHostingView(rootView: content())
            floatingWindow.backgroundColor = .clear
            floatingWindow.title = tabBarIdentifier.uuidString
            
            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            isTabBarAdded = true
            
            DispatchQueue.main.async {
                self.updateTabBarPosition()
            }
        }
    }
    
    func addPlayer(@ViewBuilder content: () -> some View) {
        guard !isPlayerAdded else { return }

        if let applicationWindow = NSApp.mainWindow {
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = NSHostingView(rootView: content())
            floatingWindow.backgroundColor = .clear
            floatingWindow.title = playerIdentifier.uuidString

            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            isPlayerAdded = true
            
            DispatchQueue.main.async {
                self.updatePlayerPosition()
            }
        }
    }
    
    func removeTabBar() {
        guard isTabBarAdded else { return }
        
        if let floatingWindow = NSApp.windows.first(where: { $0.title == tabBarIdentifier.uuidString }), let applicationWindow = NSApp.mainWindow {
            floatingWindow.close()
            applicationWindow.removeChildWindow(floatingWindow)
            isTabBarAdded = false
        }
    }
    
    func removePlayer() {
        guard isPlayerAdded else { return }
        
        if let floatingWindow = NSApp.windows.first(where: { $0.title == playerIdentifier.uuidString }), let applicationWindow = NSApp.mainWindow {
            floatingWindow.close()
            applicationWindow.removeChildWindow(floatingWindow)
            isTabBarAdded = false
        }
    }
    
    func updateTabBarPosition() {
        if let floatingWindow = NSApp.windows.first(where: { $0.title == tabBarIdentifier.uuidString }), let applicationWindow = NSApp.mainWindow {
            let windowFrame = applicationWindow.frame
            let tabBarFrame = floatingWindow.frame
            
            let centerX = windowFrame.origin.x - 75
            let bottomY = windowFrame.origin.y + (windowFrame.height - tabBarFrame.height) / 2
            
            floatingWindow.setFrame(
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
        if let floatingWindow = NSApp.windows.first(where: { $0.title == playerIdentifier.uuidString }), let applicationWindow = NSApp.mainWindow {
            let windowFrame = applicationWindow.frame
            let playerFrame = floatingWindow.frame

            let centerX = windowFrame.origin.x + (windowFrame.width - playerFrame.width) / 2
            let bottomY = windowFrame.origin.y - 50

            floatingWindow.setFrame(
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
