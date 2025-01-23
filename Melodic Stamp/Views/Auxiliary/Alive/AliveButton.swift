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

    var action: () -> ()
    @ViewBuilder var label: () -> Label

    var onGestureChanged: ((DragGesture.Value) -> ())?
    var onGestureEnded: ((DragGesture.Value) -> ())?

    private var isOn: Binding<Bool>?

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    @State private var isPressing: Bool = false
    @State private var frame: CGRect = .zero

    // MARK: Initializers - Button

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, hoveringStyle: some ShapeStyle, disabledStyle: some ShapeStyle = .quinary,
        action: @escaping () -> (),
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: ((DragGesture.Value) -> ())? = nil,
        onGestureEnded: ((DragGesture.Value) -> ())? = nil
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

        self.isOn = nil
    }

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, disabledStyle: some ShapeStyle = .quinary,
        action: @escaping () -> (),
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: ((DragGesture.Value) -> ())? = nil,
        onGestureEnded: ((DragGesture.Value) -> ())? = nil
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

        self.isOn = nil
    }

    // MARK: Initializers - Switch

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, hoveringStyle: some ShapeStyle, disabledStyle: some ShapeStyle = .quinary,
        isOn: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: ((DragGesture.Value) -> ())? = nil,
        onGestureEnded: ((DragGesture.Value) -> ())? = nil
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = .init(hoveringStyle)
        self.disabledStyle = .init(disabledStyle)
        self.onGestureChanged = onGestureChanged
        self.onGestureEnded = onGestureEnded
        self.label = label

        self.action = {}
        self.isOn = isOn
    }

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, disabledStyle: some ShapeStyle = .quinary,
        isOn: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label,
        onGestureChanged: ((DragGesture.Value) -> ())? = nil,
        onGestureEnded: ((DragGesture.Value) -> ())? = nil
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = nil
        self.disabledStyle = .init(disabledStyle)
        self.onGestureChanged = onGestureChanged
        self.onGestureEnded = onGestureEnded
        self.label = label

        self.action = {}
        self.isOn = isOn
    }

    var body: some View {
        label()
            .onAppear {
                guard let isOn else { return }
                isActive = isOn.wrappedValue
            }
            .onChange(of: isOn?.wrappedValue ?? false) { _, newValue in
                isActive = newValue
                isPressing = false
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    guard isEnabled else { return }

                    if let isOn {
                        isActive = !isOn.wrappedValue
                    } else {
                        isActive = true
                    }
                    isPressing = true

                    onGestureChanged?(gesture)
                }
                .onEnded { gesture in
                    guard isEnabled else { return }

                    // Only triggers action when location is valid (inside this view)
                    if frame.contains(gesture.location) {
                        if let isOn {
                            isOn.wrappedValue.toggle()
                        } else {
                            action()
                        }
                    }

                    if let isOn {
                        isActive = isOn.wrappedValue
                    } else {
                        isActive = false
                    }
                    isPressing = false

                    onGestureEnded?(gesture)
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
            .scaleEffect(computedScaleFactor, anchor: .center)
            .shadow(color: .black.opacity(isActive ? 0.1 : 0), radius: isActive ? shadowRadius : 0)
            .animation(hasHoveringStyle ? .default : nil, value: isHovering) // Avoid unnecessary transitions on hover
            .animation(.bouncy, value: isActive)
            .animation(.bouncy, value: isPressing)
            .animation(.default, value: isEnabled)
    }

    private var computedScaleFactor: CGFloat {
        if isPressing {
            scaleFactor * 0.95
        } else {
            isActive ? scaleFactor : 1
        }
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
    @Previewable @State var isOn = false

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

        AliveButton(isOn: $isOn) {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }

        Toggle("External", isOn: $isOn)
    }
    .padding()
}
