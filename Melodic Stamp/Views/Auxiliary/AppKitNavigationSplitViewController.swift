//
//  AppKitNavigationSplitViewController.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/7.
//

import SwiftUI

// MARK: - View Controller

class AppKitNavigationSplitViewController<Sidebar, Detail>: NSSplitViewController where Sidebar: View, Detail: View {
    var sidebarHostingController: NSHostingController<Sidebar>
    var detailHostingController: NSHostingController<Detail>

    init(sidebar: Sidebar, detail: Detail) {
        self.sidebarHostingController = NSHostingController(rootView: sidebar)
        self.detailHostingController = NSHostingController(rootView: detail)
        super.init(nibName: nil, bundle: nil)
        setupSplitView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSplitView() {
        splitView.delegate = self

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarHostingController)
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 150
        sidebarItem.maximumThickness = 150

        let detailItem = NSSplitViewItem(viewController: detailHostingController)

        addSplitViewItem(sidebarItem)
        addSplitViewItem(detailItem)
    }

    // MARK: Delegate

    override func splitView(_: NSSplitView, canCollapseSubview _: NSView) -> Bool {
        // Completely prohibits sidebar from collapsing
        false
    }

    override func splitView(_: NSSplitView, shouldHideDividerAt _: Int) -> Bool {
        // Completely prohibits sidebar from collapsing
        true
    }
}

// MARK: - View Controller Representable

struct AppKitNavigationSplitView<Sidebar, Detail>: NSViewControllerRepresentable where Sidebar: View, Detail: View {
    @ViewBuilder var sidebar: () -> Sidebar
    @ViewBuilder var detail: () -> Detail

    func makeNSViewController(context _: Context) -> AppKitNavigationSplitViewController<Sidebar, Detail> {
        let splitViewController = AppKitNavigationSplitViewController(sidebar: sidebar(), detail: detail())
        return splitViewController
    }

    func updateNSViewController(_ nsViewController: AppKitNavigationSplitViewController<Sidebar, Detail>, context _: Context) {
        nsViewController.sidebarHostingController.rootView = sidebar()
        nsViewController.detailHostingController.rootView = detail()
    }
}
