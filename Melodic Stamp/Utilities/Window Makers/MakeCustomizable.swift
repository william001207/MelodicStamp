//
//  MakeCustomizable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct MakeCustomizable: NSViewControllerRepresentable {
    var customization: (NSWindow) -> ()

    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = CustomizableWindowHostingController(rootView: EmptyView(), customization: customization)
        context.coordinator.hostingController = hostingController

        return hostingController
    }

    func updateNSViewController(_: NSViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: CustomizableWindowHostingController<EmptyView>!
    }
}

class CustomizableWindowHostingController<Content: View>: NSHostingController<Content> {
    var customization: (NSWindow) -> ()

    init(rootView: Content, customization: @escaping (NSWindow) -> ()) {
        self.customization = customization
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        guard let window = view.window else { return }
        customization(window)
    }
}
