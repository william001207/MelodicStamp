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
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareCornerRadius) private var cornerRadius
    
    private let showsLabel: Bool
    
    private var value: MetadataValueState<F.FormatInput?>
    private let format: F
    private let placeholder: LocalizedStringKey
    @ViewBuilder private let label: () -> Label
    
    @State private var isLabelHovering: Bool = false
    
    init(
        _ placeholder: LocalizedStringKey,
        value: MetadataValueState<F.FormatInput?>, format: F,
        showsLabel: Bool = true,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.showsLabel = showsLabel
        self.value = value
        self.format = format
        self.placeholder = placeholder
        self.label = label
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        value: MetadataValueState<F.FormatInput?>, format: F,
        showsLabel: Bool = true
    ) where Label == EmptyView {
        self.init(
            placeholder,
            value: value, format: format,
            showsLabel: showsLabel
        ) {
            EmptyView()
        }
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        text: MetadataValueState<String?>,
        @ViewBuilder label: @escaping () -> Label
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: text, format: StringFormatStyle(),
            label: label
        )
    }
    
    init(
        _ placeholder: LocalizedStringKey,
        text: MetadataValueState<String?>
    ) where F == StringFormatStyle, Label == EmptyView {
        self.init(
            placeholder,
            value: text, format: StringFormatStyle()
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        HStack {
            switch value {
            case .undefined:
                EmptyView()
            case .fine(let values):
                fine(values: values)
            case .varied(let valueSetter):
                varied(setter: valueSetter)
            }
        }
        .animation(animation, value: isActive)
    }
    
    private var isActive: Bool {
        switch value {
        case .undefined:
            false
        case .fine(let values):
            !isEmpty(value: values.current)
        case .varied:
            false
        }
    }
    
    @ViewBuilder private func fine(values: EditableMetadata.Values<F.FormatInput?>) -> some View {
        LuminareTextField(
            placeholder,
            value: values.projectedValue, format: format
        )
        .overlay {
            Group {
                if values.isModified {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.primary)
                        .fill(.quinary.opacity(0.5))
                        .foregroundStyle(.tint)
                }
            }
            .allowsHitTesting(false)
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
                    HStack {
                        AliveButton {
                            values.revert()
                        } label: {
                            Image(systemSymbol: .return)
                                .foregroundStyle(.tint)
                        }
                        
                        AliveButton {
                            values.current = nil
                        } label: {
                            Image(systemSymbol: .trashFill)
                                .foregroundStyle(.red)
                        }
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
    
    @ViewBuilder private func varied(setter: EditableMetadata.ValueSetter<F.FormatInput?>) -> some View {
        Color.blue
    }
    
    private func isEmpty(value: F.FormatInput?) -> Bool {
        guard let value else { return true }
        return if let value = value as? String {
            // empty strings are empty too, as placeholders will display
            value.isEmpty
        } else {
            false
        }
    }
}
