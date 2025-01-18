//
//  LabeledTextEditor.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/18.
//

import Luminare
import SwiftUI
import UniformTypeIdentifiers

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
    private var allowedFileTypes: [UTType]
    @ViewBuilder private var label: () -> Label
    @ViewBuilder private var info: () -> Info

    @State private var textInput: TextInputModel<V> = .init()

    @State private var isPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var isEditorHovering: Bool = false
    @State private var isControlsHidden: Bool = false

    init(
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        allowedFileTypes: [UTType] = [.text],
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> Info
    ) {
        self.entries = entries
        self.layout = layout
        self.style = style
        self.allowedFileTypes = allowedFileTypes
        self.label = label
        self.info = info
    }

    init(
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        allowedFileTypes: [UTType] = [.text],
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            entries: entries,
            layout: layout,
            style: style,
            allowedFileTypes: allowedFileTypes,
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
        allowedFileTypes: [UTType] = [.text],
        @ViewBuilder info: @escaping () -> Info
    ) where Label == Text {
        self.init(entries: entries, layout: layout, style: style, allowedFileTypes: allowedFileTypes) {
            Text(key)
        } info: {
            info()
        }
    }

    init(
        _ key: LocalizedStringKey,
        entries: Entries,
        layout: LabeledTextEditorLayout = .field,
        style: LabeledTextEditorStyle = .regular,
        allowedFileTypes: [UTType] = [.text]
    ) where Label == Text, Info == EmptyView {
        self.init(key, entries: entries, layout: layout, style: style, allowedFileTypes: allowedFileTypes) {
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
            .presentationSizing(.fitted)
            .frame(minWidth: 725, minHeight: 500, maxHeight: 1200)
            .onHover { hover in
                withAnimation(animationFast) {
                    isEditorHovering = hover
                }
            }
            .onChange(of: isEditorHovering) { _, newValue in
                guard newValue else { return }
                isControlsHidden = false
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: allowedFileTypes
            ) { result in
                switch result {
                case let .success(url):
                    guard url.startAccessingSecurityScopedResource() else { break }
                    defer { url.stopAccessingSecurityScopedResource() }

                    do {
                        let content = try String(contentsOf: url, encoding: .utf8)
                        entries.setAll { V.wrappingUpdate($0, with: content) }
                    } catch {
                        break
                    }
                case .failure:
                    break
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

            if !isControlsHidden {
                controls()
                    .padding(14)
            }
        }
    }

    @ViewBuilder private func codeEditor(binding _: Binding<String>) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if !isControlsHidden {
                controls()
                    .padding(14)
            }
        }
    }

    @ViewBuilder private func controls() -> some View {
        HStack {
            if Info.self != EmptyView.self {
                info()

                Divider()
            }

            AliveButton {
                entries.restoreAll()
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    HoverableLabel { isHovering in
                        Image(systemSymbol: .arrowUturnLeft)
                        if isHovering { Text("Restore") }
                    }
                }
            }
            .foregroundStyle(.red)
            .disabled(!entries.isModified)

            AliveButton {
                entries.setAll { V.wrappingUpdate($0, with: "") }
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    HoverableLabel { isHovering in
                        Image(systemSymbol: .trash)
                        if isHovering { Text("Clear") }
                    }
                }
            }
            .foregroundStyle(.red)
            .disabled(isEmpty)

            AliveButton {
                isFileImporterPresented.toggle()
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    HoverableLabel { isHovering in
                        Image(systemSymbol: .docText)
                        if isHovering { Text("Load from File") }
                    }
                }
            }

            Divider()

            AliveButton {
                isPresented = false
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    HoverableLabel { isHovering in
                        Image(systemSymbol: .xmark)
                        if isHovering { Text("Dismiss") }
                    }
                }
            }

            AliveButton {
                withAnimation(animationFast) {
                    isControlsHidden = true
                }
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    HoverableLabel { isHovering in
                        Image(systemSymbol: .chevronRight)
                        if isHovering { Text("Hide") }
                    }
                }
            }
        }
        .frame(height: 16)
        .bold()
        .padding(8)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .clipShape(.capsule)
        .shadow(color: .black.opacity(0.25), radius: 32)
        .monospaced(false)
    }
}
