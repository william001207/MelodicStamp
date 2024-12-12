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

    var state: MetadataValueState<V?>
    var defaultValue: V
    @ViewBuilder var content: (Binding<V>) -> Content
    @ViewBuilder var emptyView: () -> ContentB
    @ViewBuilder var label: () -> Label

    @State private var isHovering: Bool = false

    var body: some View {
        HStack {
            switch state {
            case .undefined:
                emptyView()
            case .fine(let entry):
                label()

                Spacer()

                if let binding = entry.projectedUnwrappedValue() {
                    if isHovering {
                        HStack(spacing: 2) {
                            AliveButton {
                                entry.restore()
                            } label: {
                                Image(systemSymbol: .arrowUturnLeft)
                            }
                            .disabled(!entry.isModified)

                            AliveButton {
                                entry.current = nil
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
                        entry.current = defaultValue
                    } label: {
                        Text("Grant a Value")
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }
            case .varied(let entries):
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
