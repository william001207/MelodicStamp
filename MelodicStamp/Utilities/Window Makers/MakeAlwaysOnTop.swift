//
//  MakeAlwaysOnTop.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/2.
//

import SwiftUI

struct MakeAlwaysOnTop: NSViewControllerRepresentable {
    @Binding var isAlwaysOnTop: Bool

    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = AlwaysOnTopWindowHostingController(rootView: EmptyView())
        context.coordinator.hostingController = hostingController

        return hostingController
    }

    func updateNSViewController(_: NSViewController, context: Context) {
        if let hostingController = context.coordinator.hostingController {
            hostingController.isAlwaysOnTop = isAlwaysOnTop
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: AlwaysOnTopWindowHostingController<EmptyView>!
    }
}

class AlwaysOnTopWindowHostingController<Content: View>: NSHostingController<Content> {
    var isAlwaysOnTop: Bool = true

    override func viewWillLayout() {
        super.viewWillLayout()

        guard let window = view.window else { return }

        window.level = isAlwaysOnTop ? .floating : .normal

        if isAlwaysOnTop {
            window.collectionBehavior.insert(.canJoinAllSpaces)
        } else {
            window.collectionBehavior.remove(.canJoinAllSpaces)
        }
    }
}
