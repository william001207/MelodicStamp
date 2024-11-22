//
//  FloatingWindowsModel.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI
import AppKit

class FloatingWindowsModel: ObservableObject {
    
    @Published private(set) var isTabBarAdded: Bool = false
    @Published private(set) var isPlayBarAdded: Bool = false
    
    @Published var selectedSidebarItem: SidebarItem = .home
    
    private let Tabid: String = UUID().uuidString
    private let Playid: String = UUID().uuidString

    func addTabBar() {
        guard !isTabBarAdded else { return }
        
        if let applicationWindow = NSApplication.shared.mainWindow {
            let customTabBar = NSHostingView(rootView: FloatingTabBarView(sections: sidebarSections, selectedItem: Binding(
                get: { self.selectedSidebarItem },
                set: { self.selectedSidebarItem = $0 }
            )).environmentObject(self))
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = customTabBar
            floatingWindow.backgroundColor = .clear
            floatingWindow.title = Tabid
            
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
            
            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            isTabBarAdded = true
        } else {
            print("NO WINDOW FOUND")
        }
    }
    
    func addPlayBar() {
        guard !isPlayBarAdded else { return }

        if let applicationWindow = NSApplication.shared.mainWindow {
            let customTabBar = NSHostingView(rootView: FloatingPlayBarView().environmentObject(self))
            let floatingWindow = NSWindow()
            floatingWindow.styleMask = .borderless
            floatingWindow.contentView = customTabBar
            floatingWindow.backgroundColor = .clear
            floatingWindow.title = Playid

            let windowFrame = applicationWindow.frame
            let playBarWidth: CGFloat = 800
            let playBarHeight: CGFloat = 100

            // Calculate the centered x position and position just below the window frame
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

            applicationWindow.addChildWindow(floatingWindow, ordered: .above)
            isPlayBarAdded = true
        } else {
            print("NO WINDOW FOUND")
        }
    }
    
    func updatePlayBarPosition() {
        if let floatingWindow = NSApplication.shared.windows.first(where: { $0.title == Playid }), let applicationWindow = NSApplication.shared.mainWindow {
            
            let windowFrame = applicationWindow.frame
            let playBarWidth: CGFloat = 800
            let playBarHeight: CGFloat = 100

            // Calculate the centered x position and position just below the window frame
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
    
    func updateTabPosition() {
        if let floatingWindow = NSApplication.shared.windows.first(where: { $0.title == Tabid }), let applicationWindow = NSApplication.shared.mainWindow {
            
            let windowSize = applicationWindow.frame.size
            let windowOrigin = applicationWindow.frame.origin
            floatingWindow.setFrameOrigin(.init(x: windowOrigin.x - 75, y: windowOrigin.y + (windowSize.height - 200) / 2))
            
        }
    }
}
