//
//  AliveButton.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SFSafeSymbols
import SwiftUI

struct AliveButton<Label>: View where Label: View {
    @Environment(\.isEnabled) private var isEnabled

    var scaleFactor: CGFloat = 0.85
    var shadowRadius: CGFloat = 4
    var duration: TimeInterval = 0.45
    var enabledStyle: AnyShapeStyle = .init(.primary)
    var hoveringStyle: AnyShapeStyle?
    var disabledStyle: AnyShapeStyle = .init(.quinary)
    var action: () -> ()
    @ViewBuilder var label: () -> Label

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    @State private var frame: CGRect = .zero

    var body: some View {
        label()
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard isEnabled else { return }
                    isActive = true
                }
                .onEnded { gesture in
                    guard isEnabled else { return }
                    isActive = false

                    // Only triggers action when location is valid (inside this view)
                    if frame.contains(gesture.location) {
                        action()
                    }
                })
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .local)
            } action: { frame in
                self.frame = frame
            }
            .onHover { hover in
                isHovering = hover
            }

            .foregroundStyle(style)
            .scaleEffect(isActive ? scaleFactor : 1, anchor: .center)
            .shadow(radius: isActive ? shadowRadius : 0)
            .animation(hasHoveringStyle ? .default : nil, value: isHovering) // Avoid unnecessary transitions on hover
            .animation(.bouncy, value: isActive)
            .animation(.default, value: isEnabled)
    }
    
    private var hasHoveringStyle: Bool {
        hoveringStyle != nil
    }
    
    private var style: AnyShapeStyle {
        if isEnabled {
            if isHovering, let hoveringStyle {
                hoveringStyle
            } else {
                enabledStyle
            }
        } else {
            disabledStyle
        }
    }
}

#Preview {
    HStack {
        AliveButton {
            print("Clicked!")
        } label: {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }

        AliveButton {
            print("Clicked!")
        } label: {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }
        .disabled(true)
    }
    .padding()
}
