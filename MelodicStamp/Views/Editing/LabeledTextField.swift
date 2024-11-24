//
//  LabeledTextField.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
import Luminare

struct LabeledTextField<F, Label>: View where F: ParseableFormatStyle, F.FormatOutput == String, F.FormatInput: Equatable, Label: View {
    @Environment(\.luminareAnimation) private var animation
    
    private let minHeight: CGFloat, horizontalPadding: CGFloat, cornerRadius: CGFloat
    private let isBordered: Bool
    private let showsLabel: Bool
    
    @Binding private var value: F.FormatInput?
    private let format: F
    private let placeholder: LocalizedStringKey
    @ViewBuilder private let label: () -> Label
    
    @State private var isLabelHovering: Bool = false
    
    init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true,
        showsLabel: Bool = true,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.minHeight = minHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.isBordered = isBordered
        self.showsLabel = showsLabel
        self._value = value
        self.format = format
        self.placeholder = placeholder
        self.label = label
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true,
        showsLabel: Bool = true
    ) where Label == EmptyView {
        self.init(
            placeholder,
            value: value, format: format,
            minHeight: minHeight, horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            isBordered: isBordered,
            showsLabel: showsLabel
        ) {
            EmptyView()
        }
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String?>,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true,
        @ViewBuilder label: @escaping () -> Label
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: text, format: StringFormatStyle(),
            minHeight: minHeight, horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            isBordered: isBordered,
            label: label
        )
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String?>,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true
    ) where F == StringFormatStyle, Label == EmptyView {
        self.init(
            placeholder,
            value: text, format: StringFormatStyle(),
            minHeight: minHeight, horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            isBordered: isBordered
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        HStack {
            LuminareTextField(
                placeholder,
                value: $value, format: format,
                minHeight: minHeight, horizontalPadding: horizontalPadding,
                cornerRadius: cornerRadius,
                isBordered: isBordered
            )
            .onKeyPress(keys: [.delete], phases: .down) { key in
                guard key.modifiers.contains(.command) else { return .ignored }
                value = nil
                return .handled
            }
            
            if showsLabel && isActive {
                Group {
                    if Label.self != EmptyView.self {
                        label()
                    } else {
                        Text(placeholder)
                    }
                }
                .blur(radius: isLabelHovering ? 8 : 0)
                .overlay {
                    if isLabelHovering {
                        AliveButton {
                            value = nil
                        } label: {
                            Image(systemSymbol: .trashFill)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .foregroundStyle(.secondary)
                .frame(height: minHeight)
                .fixedSize()
                .onHover { hover in
                    withAnimation {
                        isLabelHovering = hover
                    }
                }
            }
        }
        .animation(animation, value: isActive)
    }
    
    private var isActive: Bool {
        guard let value else { return false }
        return if let value = value as? String {
            !value.isEmpty
        } else {
            true
        }
    }
}

#Preview {
    @Previewable @State var text: String?
    @Previewable @State var value: Int?
    
    LabeledTextField("Placeholder (String)", text: $text)
    LabeledTextField("Placeholder (Int)", value: $value, format: .number)
}
