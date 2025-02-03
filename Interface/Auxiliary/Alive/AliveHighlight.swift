//
//  AliveHighlight.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/2.
//

import Luminare
import SwiftUI

struct AliveHighlight<Content>: View where Content: View {
    @Environment(\.luminareAnimation) private var animation

    var isHighlighted: Bool = false
    var cornerRadius: CGFloat = 8
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(.quaternary)
                        .padding(-4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(animation, value: isHighlighted)
    }
}

struct AliveHighlightViewModifier: ViewModifier {
    var isHighlighted: Bool = false
    var cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        AliveHighlight(isHighlighted: isHighlighted, cornerRadius: cornerRadius) {
            content
        }
    }
}

#Preview {
    @Previewable @State var isHighlighted = false

    Button {
        isHighlighted.toggle()
    } label: {
        AliveHighlight(isHighlighted: isHighlighted) {
            Text("Highlight Me!")
        }
    }
    .buttonStyle(.alive)
    .padding()
}
