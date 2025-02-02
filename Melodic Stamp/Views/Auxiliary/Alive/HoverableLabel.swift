//
//  HoverableLabel.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/4.
//

import Luminare
import SwiftUI

struct HoverableLabel<Content>: View where Content: View {
    @Environment(\.luminareAnimationFast) private var animationFast

    @ViewBuilder var content: (Bool) -> Content

    var isExternallyHovering: Bool?

    @State private var isInternallyHovering: Bool = false

    var body: some View {
        content(isHovering)
            .animation(animationFast, value: isHovering)
            .onHover { hover in
                isInternallyHovering = hover
            }
    }

    private var isHovering: Bool {
        isExternallyHovering ?? isInternallyHovering
    }
}

#Preview {
    HoverableLabel { isHovering in
        HStack {
            Text("First")

            if isHovering {
                Text("Second")
            }
        }
        .fixedSize()
        .background(.quinary)
    }
    .fixedSize()
    .padding()
}
