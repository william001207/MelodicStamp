//
//  TTMLInspectorInformationView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/22.
//

import Luminare
import SFSafeSymbols
import SwiftUI

struct TTMLInspectorInformationView<Content>: View where Content: View {
    @Environment(\.luminareAnimationFast) private var animationFast

    var systemSymbol: SFSymbol
    @ViewBuilder var content: () -> Content

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            Image(systemSymbol: systemSymbol)
                .padding(2)
                .frame(width: 16, height: 16)

            content()
        }
        .font(.subheadline)
        .opacity(isHovering ? 1 : 0.6)
        .onHover { hover in
            withAnimation(animationFast) {
                isHovering = hover
            }
        }
    }
}

#Preview {
    TTMLInspectorInformationView(systemSymbol: .characterPhonetic) {
        Text("Roman")
    }
}
