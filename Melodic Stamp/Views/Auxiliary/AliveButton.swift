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

    var scaleFactor: CGFloat
    var shadowRadius: CGFloat
    var duration: TimeInterval
    
    var enabledStyle: AnyShapeStyle
    var hoveringStyle: AnyShapeStyle?
    var disabledStyle: AnyShapeStyle
    
    var onGestureChanged: (DragGesture.Value) -> Void
    var onGestureEnded: (DragGesture.Value) -> Void
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    @State private var frame: CGRect = .zero
    
    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, hoveringStyle: some ShapeStyle, disabledStyle: some ShapeStyle = .quinary,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onGestureEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = .init(hoveringStyle)
        self.disabledStyle = .init(disabledStyle)
        self.onGestureChanged = onGestureChanged
        self.onGestureEnded = onGestureEnded
        self.action = action
        self.label = label
    }
    
    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, disabledStyle: some ShapeStyle = .quinary,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onGestureEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = nil
        self.disabledStyle = .init(disabledStyle)
        self.onGestureChanged = onGestureChanged
        self.onGestureEnded = onGestureEnded
        self.action = action
        self.label = label
    }

    var body: some View {
        label()
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    guard isEnabled else { return }
                    isActive = true
                    
                    onGestureChanged(gesture)
                }
                .onEnded { gesture in
                    guard isEnabled else { return }
                    isActive = false

                    // Only triggers action when location is valid (inside this view)
                    if frame.contains(gesture.location) {
                        action()
                    }
                    
                    onGestureEnded(gesture)
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
