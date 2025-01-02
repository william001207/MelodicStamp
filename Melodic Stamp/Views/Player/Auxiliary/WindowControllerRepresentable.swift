//
//  WindowControllerRepresentable.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/2.
//

import SwiftUI

struct WindowControllerRepresentable: NSViewControllerRepresentable {
    @Binding var isFloating: Bool
    @Binding var isTitleBarHidden: Bool

    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = CustomHostingController(rootView: EmptyView())
        hostingController.isFloating = isFloating
        hostingController.isTitleBarHidden = isTitleBarHidden
        context.coordinator.hostingController = hostingController
        return hostingController
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        if let hostingController = context.coordinator.hostingController {
            hostingController.isFloating = isFloating
            hostingController.isTitleBarHidden = isTitleBarHidden
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: CustomHostingController<EmptyView>!
    }
}

class CustomHostingController<Content: View>: NSHostingController<Content> {
    var isFloating: Bool = false
    var isTitleBarHidden: Bool = false

    override func viewWillLayout() {
        super.viewWillLayout()

        if let window = self.view.window {
            
            if isTitleBarHidden {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.titlebarSeparatorStyle = .none
            }
            
            window.level = isFloating ? .floating : .normal
            
            if isFloating {
                window.collectionBehavior.insert(.canJoinAllSpaces)
            } else {
                window.collectionBehavior.remove(.canJoinAllSpaces)
            }
        }
    }
}
