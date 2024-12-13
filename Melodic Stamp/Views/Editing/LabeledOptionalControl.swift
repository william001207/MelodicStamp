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
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight

    var entries: MetadataBatchEditingEntries<V?>
    var defaultValue: V
    @ViewBuilder var content: (Binding<V>) -> Content
    @ViewBuilder var emptyView: () -> ContentB
    @ViewBuilder var label: () -> Label

    @State private var isHovering: Bool = false

    var body: some View {
        HStack {
            switch entries.type {
            case .none:
                emptyView()
            case .identical:
                label()

                Spacer()

                if let binding = entries.projectedUnwrappedValue() {
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
                        }
                        .foregroundStyle(.red)
                        .bold()
                    }

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

                Spacer()

                Color.blue
            }
        }
        .frame(minHeight: minHeight)
        .onHover { hover in
            withAnimation(animationFast) {
                isHovering = hover
            }
        }
    }
}
