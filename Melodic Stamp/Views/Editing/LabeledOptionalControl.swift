//
//  LabeledOptionalControl.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/12.
//

import Luminare
import SwiftUI

struct LabeledOptionalControl<V, Label, Content, ContentB>: View
    where V: Hashable & Equatable, Label: View, Content: View, ContentB: View {
    typealias Entries = MetadataBatchEditingEntries<V?>

    @Environment(\.undoManager) private var undoManager
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight

    var entries: Entries
    var defaultValue: V
    @ViewBuilder var content: (Binding<V>) -> Content
    @ViewBuilder var emptyView: () -> ContentB
    @ViewBuilder var label: () -> Label

    @State private var isHovering: Bool = false
    @State private var undoTargetCheckpoint: Checkpoint<V?> = .invalid

    var body: some View {
        HStack {
            switch entries.type {
            case .none:
                emptyView()
            case .identical:
                label()

                Spacer()

                if isHovering {
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
                        .disabled(!hasValue)
                    }
                    .foregroundStyle(.red)
                    .bold()
                    .animation(.bouncy, value: entries.isModified) // To match the animation in `AliveButton`
                }

                if let binding = entries.projectedUnwrappedValue() {
                    content(binding)
                } else {
                    Button {
                        entries.setAll(defaultValue)
                    } label: {
                        Text("Grant a Value")
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }
            case .varied:
                label()
                    .italic()

                Spacer()

                Button {
                    entries.setAll(defaultValue)
                } label: {
                    Text("Multiple Values")
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
                .italic()
            }
        }
        .modifier(LuminareHoverable())
        .luminareAspectRatio(contentMode: .fill)
        .onHover { hover in
            withAnimation(animationFast) {
                isHovering = hover
            }
        }
        .onChange(of: entries.projectedValue?.wrappedValue) { oldValue, _ in
            registerUndo(oldValue, for: entries)
        }
    }

    private var hasValue: Bool {
        entries.projectedUnwrappedValue() != nil
    }

    private func registerUndo(_ oldValue: V?, for entries: Entries) {
        let value = entries.projectedUnwrappedValue()?.wrappedValue
        guard oldValue != value else { return }

        switch undoTargetCheckpoint {
        case .invalid:
            break
        case let .valid(value):
            guard oldValue != value else { return }
        }
        undoTargetCheckpoint.set(oldValue)

        undoManager?.registerUndo(withTarget: entries) { entries in
            let fallback = entries.projectedUnwrappedValue()?.wrappedValue
            entries.setAll(oldValue)

            registerUndo(fallback, for: entries)
        }
    }

    private func withUndo(for entries: Entries, _ body: @escaping () -> ()) {
        let fallback = entries.projectedUnwrappedValue()?.wrappedValue
        body()
        registerUndo(fallback, for: entries)
    }
}
