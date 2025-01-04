//
//  LabeledTextEditor.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/18.
//

import Luminare
import SwiftUI

enum LabeledTextEditorLayout {
    case field
    case button
}

enum LabeledTextEditorStyle {
    case regular
}

struct LabeledTextEditor<Label, Info, V>: View where Label: View, Info: View, V: StringRepresentable & Hashable {
    typealias Entries = MetadataBatchEditingEntries<V?>

    @Environment(\.undoManager) private var undoManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    private var entries: Entries
    private var layout: LabeledTextEditorLayout
    private var style: LabeledTextEditorStyle
    @ViewBuilder private var label: () -> Label
    @ViewBuilder private var info: () -> Info

    @State private var textInput: TextInputModel<V> = .init()

    @State private var isPresented: Bool = false
    @State private var isEditorHovering: Bool = false
    @State private var isControlsHidden: Bool = false

    init(
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> Info
    ) {
        self.entries = entries
        self.layout = layout
        self.style = style
        self.label = label
        self.info = info
    }

    init(
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            entries: entries,
            layout: layout,
            style: style,
            label: label
        ) {
            EmptyView()
        }
    }

    init(
        _ key: LocalizedStringKey,
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        @ViewBuilder info: @escaping () -> Info
    ) where Label == Text {
        self.init(entries: entries, layout: layout, style: style) {
            Text(key)
        } info: {
            info()
        }
    }

    init(
        _ key: LocalizedStringKey,
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular
    ) where Label == Text, Info == EmptyView {
        self.init(key, entries: entries, layout: layout, style: style) {
            EmptyView()
        }
    }

    var body: some View {
        let isModified = entries.isModified
        let binding: Binding<String> = Binding {
            entries.projectedUnwrappedValue()?.wrappedValue.stringRepresentation ?? ""
        } set: { newValue in
            entries.setAll { V.wrappingUpdate($0, with: newValue) }
        }

        Group {
            switch layout {
            case .field:
                HStack {
                    HStack {
                        label()

                        Spacer()

                        if !isEmpty {
                            Text("\(binding.wrappedValue.count) words")
                                .foregroundStyle(.placeholder)
                        }
                    }
                    .modifier(LuminareHoverable())
                    .luminareAspectRatio(contentMode: .fill)
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

                    AliveButton {
                        isPresented.toggle()
                    } label: {
                        Image(systemSymbol: .textRedaction)
                            .foregroundStyle(.tint)
                            .tint(isModified ? .accent : .secondary)
                    }
                }
            case .button:
                Button {
                    isPresented.toggle()
                } label: {
                    label()
                }
            }
        }
        .onAppear {
            textInput.updateCheckpoint(for: entries)
        }
        .onChange(of: isPresented, initial: true) { _, newValue in
            if newValue {
                textInput.updateCheckpoint(for: entries)
            } else {
                textInput.registerUndoFromCheckpoint(for: entries, in: undoManager)
            }
        }
        .onChange(of: entries.projectedValue?.wrappedValue) { oldValue, _ in
            guard !isPresented else { return }
            textInput.registerUndo(oldValue, for: entries, in: undoManager)
        }
        .sheet(isPresented: $isPresented) {
            Group {
                switch style {
                case .regular:
                    regularEditor(binding: binding)
                }
            }
            .frame(minWidth: 640, minHeight: 520)
            .onHover { hover in
                withAnimation(animationFast) {
                    isEditorHovering = hover

                    if hover {
                        isControlsHidden = false
                    }
                }
            }
        }
    }

    private var isEmpty: Bool {
        if let binding = entries.projectedValue {
            textInput.isEmpty(value: binding.wrappedValue)
        } else {
            true
        }
    }

    @ViewBuilder private func regularEditor(binding: Binding<String>) -> some View {
        ZStack(alignment: .topTrailing) {
            LuminareTextEditor(text: binding)
                .luminareBordered(false)
                .luminareHasBackground(false)

            if isEditorHovering, !isControlsHidden {
                controls()
                    .padding(14)
            }
        }
    }

    @ViewBuilder private func codeEditor(binding: Binding<String>) -> some View {
        ZStack(alignment: .bottomTrailing) {

            if isEditorHovering, !isControlsHidden {
                controls()
                    .padding(14)
            }
        }
    }

    @ViewBuilder private func controls() -> some View {
        HStack(spacing: 2) {
            if Info.self != EmptyView.self {
                info()

                Spacer()
                    .frame(width: 8)
            }

            AliveButton {
                entries.restoreAll()
            } label: {
                Image(systemSymbol: .arrowUturnLeft)
            }
            .foregroundStyle(.red)
            .disabled(!entries.isModified)

            AliveButton {
                entries.setAll { V.wrappingUpdate($0, with: "") }
            } label: {
                Image(systemSymbol: .trash)
            }
            .foregroundStyle(.red)
            .disabled(isEmpty)

            Spacer()
                .frame(width: 8)

            AliveButton {
                isPresented = false
            } label: {
                Image(systemSymbol: .xmark)
            }

            AliveButton {
                withAnimation(animationFast) {
                    isControlsHidden = true
                }
            } label: {
                Image(systemSymbol: .chevronRight)
            }
        }
        .bold()
        .padding(8)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .clipShape(.capsule)
        .shadow(color: .black.opacity(0.25), radius: 32)
    }
}
