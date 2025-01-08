//
//  GradientBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/8.
//

import SwiftUI

struct GradientBackgroundView<Content>: View where Content: View {
    var color: Color = .accent
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .shadow(radius: 1.5, y: 1)
            .background {
                color

                LinearGradient(
                    colors: [.white, .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .opacity(0.35)
                .blendMode(.luminosity)
            }
    }
}

struct GradientBackgroundModifier: ViewModifier {
    var color: Color = .accent

    func body(content: Content) -> some View {
        GradientBackgroundView(color: color) {
            content
        }
    }
}

#Preview {
    GradientBackgroundView {
        Image(systemSymbol: .gear)
            .font(.title)
    }
    .clipShape(.rect(cornerRadius: 8))
    .padding()
}
