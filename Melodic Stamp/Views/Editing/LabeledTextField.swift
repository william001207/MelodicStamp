//
//  LabeledTextField.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SwiftUI

struct LabeledTextField<F, Label>: View where F: ParseableFormatStyle, F.FormatOutput == String, F.FormatInput: Equatable & Hashable, Label: View {
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareCompactButtonCornerRadius) private var buttonCornerRadius

    private var state: MetadataValueState<F.FormatInput?>
    private let format: F
    private let placeholder: LocalizedStringKey
    private let showsLabel: Bool
    @ViewBuilder private let label: () -> Label

    @State private var isLabelHovering: Bool = false

    init(
        _ placeholder: LocalizedStringKey,
        state: MetadataValueState<F.FormatInput?>, format: F,
        showsLabel: Bool = true,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.state = state
        self.format = format
        self.placeholder = placeholder
        self.showsLabel = showsLabel
        self.label = label
    }

    init(
        _ placeholder: LocalizedStringKey,
        state: MetadataValueState<F.FormatInput?>, format: F,
        showsLabel: Bool = true
    ) where Label == EmptyView {
        self.init(
            placeholder,
            state: state, format: format,
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
            state: text, format: StringFormatStyle(),
            label: label
        )
    }

    init(
        _ placeholder: LocalizedStringKey,
        text: MetadataValueState<String?>
    ) where F == StringFormatStyle, Label == EmptyView {
        self.init(
            placeholder,
            state: text, format: StringFormatStyle()
        ) {
            EmptyView()
        }
    }

    var body: some View {
        HStack {
            switch state {
            case .undefined:
                EmptyView()
            case let .fine(value):
                fine(value: value)
            case let .varied(values):
                varied(values: values)
            }
        }
        .animation(animation, value: isActive)
    }

    private var isActive: Bool {
        switch state {
        case .undefined:
            false
        case let .fine(values):
            !isEmpty(value: values.current)
        case .varied:
            false
        }
    }

    @ViewBuilder private func fine(value: EditableMetadata.Value<F.FormatInput?>) -> some View {
        LuminareTextField(
            placeholder,
            value: value.projectedValue, format: format
        )
        .overlay {
            Group {
                if value.isModified {
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
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
                    HStack(spacing: 2) {
                        AliveButton {
                            value.revert()
                        } label: {
                            Image(systemSymbol: .arrowUturnLeft)
                        }
                        .disabled(!value.isModified)

                        AliveButton {
                            value.current = nil
                        } label: {
                            Image(systemSymbol: .trash)
                        }
                    }
                    .foregroundStyle(.red)
                    .bold()
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

    @ViewBuilder private func varied(values: EditableMetadata.Values<F.FormatInput?>) -> some View {
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
