//
//  AlwaysOnTopControllerRepresentable.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/2.
//

import SwiftUI

struct AlwaysOnTopControllerRepresentable: NSViewControllerRepresentable {
    @Binding var isAlwaysOnTop: Bool
    @Binding var titleVisibility: NSWindow.TitleVisibility

    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = AlwaysOnTopHostingController(rootView: EmptyView())
        context.coordinator.hostingController = hostingController

        return hostingController
    }

    func updateNSViewController(_: NSViewController, context: Context) {
        if let hostingController = context.coordinator.hostingController {
            hostingController.isAlwaysOnTop = isAlwaysOnTop
            hostingController.titleVisibility = titleVisibility
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: AlwaysOnTopHostingController<EmptyView>!
    }
}

class AlwaysOnTopHostingController<Content: View>: NSHostingController<Content> {
    var isAlwaysOnTop: Bool = true
    var titleVisibility: NSWindow.TitleVisibility = .hidden

    override func viewWillLayout() {
        super.viewWillLayout()

        if let window = view.window {
            switch titleVisibility {
            case .visible:
                // Handled by SwiftUI
                break
            case .hidden:
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.titlebarSeparatorStyle = .none
            @unknown default:
                break
            }

            window.level = isAlwaysOnTop ? .floating : .normal

            if isAlwaysOnTop {
                window.collectionBehavior.insert(.canJoinAllSpaces)
            } else {
                window.collectionBehavior.remove(.canJoinAllSpaces)
            }
        }
    }
}
