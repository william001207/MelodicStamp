//
//  LabeledTextField.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SwiftUI

struct LabeledTextField<F, Label>: View where F: ParseableFormatStyle, F.FormatOutput == String, F.FormatInput: Equatable & Hashable, Label: View {
    typealias Entries = MetadataBatchEditingEntries<F.FormatInput?>
    
    @FocusState private var isFocused: Bool

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    private var entries: Entries
    private let format: F
    private let placeholder: LocalizedStringKey
    private let showsLabel: Bool
    @ViewBuilder private let label: () -> Label

    @State private var isLabelHovering: Bool = false

    init(
        _ placeholder: LocalizedStringKey,
        entries: Entries, format: F,
        showsLabel: Bool = true,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.entries = entries
        self.format = format
        self.placeholder = placeholder
        self.showsLabel = showsLabel
        self.label = label
    }

    init(
        _ placeholder: LocalizedStringKey,
        entries: Entries, format: F,
        showsLabel: Bool = true
    ) where Label == EmptyView {
        self.init(
            placeholder,
            entries: entries, format: format,
            showsLabel: showsLabel
        ) {
            EmptyView()
        }
    }

    init(
        _ placeholder: LocalizedStringKey,
        text: MetadataBatchEditingEntries<String?>,
        @ViewBuilder label: @escaping () -> Label
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            entries: text, format: StringFormatStyle(),
            label: label
        )
    }

    init(
        _ placeholder: LocalizedStringKey,
        text: MetadataBatchEditingEntries<String?>
    ) where F == StringFormatStyle, Label == EmptyView {
        self.init(
            placeholder,
            entries: text, format: StringFormatStyle()
        ) {
            EmptyView()
        }
    }

    var body: some View {
        HStack {
            if let binding = entries.projectedValue {
                identical(binding: binding)
            } else {
                varied()
            }
        }
        .animation(animation, value: isActive)
        .animation(animation, value: entries.isModified)
    }

    private var isActive: Bool {
        if let binding = entries.projectedValue {
            !isEmpty(value: binding.wrappedValue)
        } else {
            false
        }
    }

    @ViewBuilder private func identical(binding: Binding<F.FormatInput?>) -> some View {
        LuminareTextField(
            placeholder,
            value: binding, format: format
        )
        .luminareCompactButtonAspectRatio(contentMode: .fill)
        .focused($isFocused)
        .onSubmit {
            isFocused = false
        }
        .overlay {
            Group {
                if entries.isModified {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .stroke(.primary)
                        .fill(.quinary.opacity(0.5))
                        .foregroundStyle(.tint)
                }
            }
            .allowsHitTesting(false)
        }

        if showsLabel, isActive {
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
                            entries.restoreAll()
                        } label: {
                            Image(systemSymbol: .arrowUturnLeft)
                        }
                        .disabled(!entries.isModified)

                        AliveButton {
                            entries.setAll(nil)
                        } label: {
                            Image(systemSymbol: .trash)
                        }
                    }
                    .foregroundStyle(.red)
                    .bold()
                    .animation(.bouncy, value: entries.isModified) // To match the animation in `AliveButton`
                }
            }
            .foregroundStyle(.secondary)
            .frame(height: minHeight)
            .fixedSize()
            .onHover { hover in
                withAnimation(animationFast) {
                    isLabelHovering = hover
                }
            }
        }
    }

    @ViewBuilder private func varied() -> some View {
        Button {
            entries.setAll(nil)
            DispatchQueue.main.async {
                isFocused = true
            }
        } label: {
            HStack(spacing: 0) {
                if Label.self != EmptyView.self {
                    label()
                } else {
                    Text(placeholder)
                }
                
                Spacer()
            }
        }
        .italic()
        .foregroundStyle(.secondary)
        .buttonStyle(.luminareCompact)
        .luminareCompactButtonAspectRatio(contentMode: .fill)
    }

    private func isEmpty(value: F.FormatInput?) -> Bool {
        guard let value else { return true }
        return if let value = value as? String {
            // Empty strings are empty too, as placeholders will display
            value.isEmpty
        } else {
            false
        }
    }
}
