//
//  AliveButtonStyle.swift
//  Playground
//
//  Created by KrLite on 2025/1/27.
//

//
//  AliveButton.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SFSafeSymbols
import SwiftUI

struct AliveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var scaleFactor: CGFloat
    var shadowRadius: CGFloat
    var duration: TimeInterval

    var enabledStyle: AnyShapeStyle
    var hoveringStyle: AnyShapeStyle?
    var disabledStyle: AnyShapeStyle

    private var isOn: Binding<Bool>?

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    @State private var isPressed: Bool = false

    // MARK: Initializers - Button

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, hoveringStyle: some ShapeStyle, disabledStyle: some ShapeStyle = .quinary
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = .init(hoveringStyle)
        self.disabledStyle = .init(disabledStyle)

        self.isOn = nil
    }

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, disabledStyle: some ShapeStyle = .quinary
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = nil
        self.disabledStyle = .init(disabledStyle)

        self.isOn = nil
    }

    // MARK: Initializers - Switch

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, hoveringStyle: some ShapeStyle, disabledStyle: some ShapeStyle = .quinary,
        isOn: Binding<Bool>
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = .init(hoveringStyle)
        self.disabledStyle = .init(disabledStyle)

        self.isOn = isOn
    }

    init(
        scaleFactor: CGFloat = 0.85, shadowRadius: CGFloat = 4, duration: TimeInterval = 0.45,
        enabledStyle: some ShapeStyle = .primary, disabledStyle: some ShapeStyle = .quinary,
        isOn: Binding<Bool>
    ) {
        self.scaleFactor = scaleFactor
        self.shadowRadius = shadowRadius
        self.duration = duration
        self.enabledStyle = .init(enabledStyle)
        self.hoveringStyle = nil
        self.disabledStyle = .init(disabledStyle)

        self.isOn = isOn
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onAppear {
                guard let isOn else { return }
                isActive = isOn.wrappedValue
            }
            .onChange(of: isOn?.wrappedValue ?? false) { _, newValue in
                isActive = newValue
                isPressed = false
            }
            .onChange(of: configuration.isPressed) { _, newValue in
                guard isEnabled else { return }
                isPressed = newValue
                if newValue {
                    if let isOn {
                        isActive = !isOn.wrappedValue
                    } else {
                        isActive = true
                    }
                } else {
                    if let isOn {
                        isOn.wrappedValue.toggle()
                        isActive = isOn.wrappedValue
                    } else {
                        isActive = false
                    }
                }
            }
            .foregroundStyle(style)
            .scaleEffect(computedScaleFactor, anchor: .center)
            .shadow(color: .black.opacity(isActive ? 0.1 : 0), radius: isActive ? shadowRadius : 0)
            .animation(hasHoveringStyle ? .default : nil, value: isHovering) // Avoids unnecessary transitions on hover
            .animation(.bouncy, value: isActive)
            .animation(.bouncy, value: isPressed)
            .animation(.default, value: isEnabled)
            .onHover { hover in
                isHovering = hover
            }
    }

    private var computedScaleFactor: CGFloat {
        if isPressed {
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
        Button {
            print("Clicked!")
        } label: {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }

        Button {
            print("Clicked!")
        } label: {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }
        .disabled(true)

        Button {} label: {
            Image(systemSymbol: .appleLogo)
                .imageScale(.large)
        }
        .buttonStyle(AliveButtonStyle(isOn: $isOn))

        Toggle("External", isOn: $isOn)
    }
    .buttonStyle(AliveButtonStyle())
    .padding()
}
