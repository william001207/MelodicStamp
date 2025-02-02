//
//  DoubleClickListeningView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//  https://gist.github.com/joelekstrom/91dad79ebdba409556dce663d28e8297
//

import SwiftUI

struct DoubleClickHandler: ViewModifier {
    let handler: () -> ()

    func body(content: Content) -> some View {
        content.overlay {
            DoubleClickListeningViewRepresentable(handler: handler)
        }
    }
}

struct DoubleClickListeningViewRepresentable: NSViewRepresentable {
    let handler: () -> ()

    func makeNSView(context _: Context) -> DoubleClickListeningView {
        DoubleClickListeningView(handler: handler)
    }

    func updateNSView(_: DoubleClickListeningView, context _: Context) {}
}

class DoubleClickListeningView: NSView {
    let handler: () -> ()

    init(handler: @escaping () -> ()) {
        self.handler = handler
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if event.clickCount == 2 {
            handler()
        }
    }
}

#Preview {
    Color.red
        // The order is important for both to work!!
        .onDoubleClick {
            print(1)
        }
        .onHover { hover in
            print(hover)
        }
}
