//
//  AppKitNavigationSplitViewController.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/7.
//

import SwiftUI

class AppKitNavigationSplitViewController<Sidebar: View, Detail: View>: NSSplitViewController {
    
    var sidebarHostingController: NSHostingController<Sidebar>
    var detailHostingController: NSHostingController<Detail>
    
    init(sidebar: Sidebar, detail: Detail) {
        self.sidebarHostingController = NSHostingController(rootView: sidebar)
        self.detailHostingController = NSHostingController(rootView: detail)
        super.init(nibName: nil, bundle: nil)
        setupSplitView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private func setupSplitView() {
        self.splitView.delegate = self
        
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarHostingController)
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 150
        sidebarItem.maximumThickness = 150
        
        let detailItem = NSSplitViewItem(viewController: detailHostingController)
        
        self.addSplitViewItem(sidebarItem)
        self.addSplitViewItem(detailItem)
    }
    
    // MARK: - NSSplitViewDelegate
    
    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        return true
    }
}

// MARK: - NSViewControllerRepresentable

struct AppKitNavigationSplitView<Sidebar: View, Detail: View>: NSViewControllerRepresentable {
    
    let sidebar: () -> Sidebar
    let detail: () -> Detail
    
    func makeNSViewController(context: Context) -> AppKitNavigationSplitViewController<Sidebar, Detail> {
        let splitViewController = AppKitNavigationSplitViewController(sidebar: sidebar(), detail: detail())
        return splitViewController
    }
    
    func updateNSViewController(_ nsViewController: AppKitNavigationSplitViewController<Sidebar, Detail>, context: Context) {
        nsViewController.sidebarHostingController.rootView = sidebar()
        nsViewController.detailHostingController.rootView = detail()
    }
}
