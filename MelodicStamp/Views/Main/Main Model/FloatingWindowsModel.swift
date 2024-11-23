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
    private(set) var isPlayBarAdded: Bool = false
    
    private var tabBarIdentifier: NSUserInterfaceItemIdentifier?
    private var playerIdentifier: NSUserInterfaceItemIdentifier?
    
    @State var selectedSidebarItem: SidebarItem = .home

    func addTabBar() {
        guard !isTabBarAdded else { return }
        
        if let applicationWindow = NSApp.mainWindow {
            let content = NSHostingView(rootView: FloatingTabBarView(model: self, sections: sidebarSections, selectedItem: $selectedSidebarItem))
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = content
            floatingWindow.backgroundColor = .clear
            
            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            tabBarIdentifier = floatingWindow.identifier
            isTabBarAdded = true
            updateTabBarPosition()
        }
    }
    
    func addPlayer() {
        guard !isPlayBarAdded else { return }

        if let applicationWindow = NSApp.mainWindow {
            let content = NSHostingView(rootView: FloatingPlayerView(model: self))
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = content
            floatingWindow.backgroundColor = .clear

            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            playerIdentifier = floatingWindow.identifier
            isPlayBarAdded = true
            updatePlayerPosition()
        }
    }
    
    func updateTabBarPosition() {
        if let floatingWindow = NSApp.windows.first(where: { $0.identifier == tabBarIdentifier }), let applicationWindow = NSApp.mainWindow {
            let windowSize = applicationWindow.frame.size
            let windowOrigin = applicationWindow.frame.origin
            
            let playBarWidth: CGFloat = 55
            let playBarHeight: CGFloat = 200
            
            let centeredX = windowOrigin.x - 75
            let bottomY = windowOrigin.y + (windowSize.height - 200) / 2
            
            floatingWindow.setFrame(
                NSRect(
                    x: centeredX,
                    y: bottomY,
                    width: playBarWidth,
                    height: playBarHeight
                ),
                display: true
            )
        }
    }
    
    func updatePlayerPosition() {
        if let floatingWindow = NSApp.windows.first(where: { $0.identifier == playerIdentifier }), let applicationWindow = NSApp.mainWindow {
            let windowFrame = applicationWindow.frame
            let playBarWidth: CGFloat = 800
            let playBarHeight: CGFloat = 100

            let centeredX = windowFrame.origin.x + (windowFrame.width - playBarWidth) / 2
            let bottomY = windowFrame.origin.y - 50

            floatingWindow.setFrame(
                NSRect(
                    x: centeredX,
                    y: bottomY,
                    width: playBarWidth,
                    height: playBarHeight
                ),
                display: true
            )
        }
    }
}
