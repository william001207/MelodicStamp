//
//  MakeCustomizable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct MakeCustomizable: NSViewControllerRepresentable {
    var customization: ((NSWindow) -> ())?
    var willAppear: ((NSWindow) -> ())?
    var didAppear: ((NSWindow) -> ())?
    var willDisappear: ((NSWindow) -> ())?
    var didDisappear: ((NSWindow) -> ())?

    func makeNSViewController(context: Context) -> NSViewController {
        let hostingController = CustomizableWindowHostingController(
            rootView: EmptyView(), customization: customization,
            willAppear: willAppear, didAppear: didAppear,
            willDisappear: willDisappear, didDisappear: didDisappear
        )
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
    var customization: ((NSWindow) -> ())?
    var willAppear: ((NSWindow) -> ())?
    var didAppear: ((NSWindow) -> ())?
    var willDisappear: ((NSWindow) -> ())?
    var didDisappear: ((NSWindow) -> ())?

    init(
        rootView: Content, customization: ((NSWindow) -> ())? = nil,
        willAppear: ((NSWindow) -> ())? = nil, didAppear: ((NSWindow) -> ())? = nil,
        willDisappear: ((NSWindow) -> ())? = nil, didDisappear: ((NSWindow) -> ())? = nil
    ) {
        self.customization = customization
        self.willAppear = willAppear
        self.didAppear = didAppear
        self.willDisappear = willDisappear
        self.didDisappear = didDisappear
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        guard let window = view.window else { return }
        customization?(window)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        guard let window = view.window else { return }
        willAppear?(window)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        guard let window = view.window else { return }
        didAppear?(window)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        guard let window = view.window else { return }
        willDisappear?(window)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        guard let window = view.window else { return }
        didDisappear?(window)
    }
}
