//
//  MakeTitledWindow.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct MakeTitledWindow: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = TitledWindowHostingController(rootView: EmptyView())
        context.coordinator.hostingController = hostingController

        return hostingController
    }

    func updateNSViewController(_: NSViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: TitledWindowHostingController<EmptyView>!
    }
}

class TitledWindowHostingController<Content: View>: NSHostingController<Content> {
    override func viewWillLayout() {
        super.viewWillLayout()

        guard let window = view.window else { return }

        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = false
        window.titlebarSeparatorStyle = .automatic
        window.makeKeyAndOrderFront(true)
    }
}
