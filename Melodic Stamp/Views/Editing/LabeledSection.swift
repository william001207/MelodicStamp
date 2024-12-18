//
//  LabeledSection.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SwiftUI

struct LabeledSection<Content, Label>: View where Content: View, Label: View {
    @Environment(\.luminareAnimation) private var animation

    @ViewBuilder private var content: () -> Content
    @ViewBuilder private var label: () -> Label

    @State private var isExpanded: Bool = true

    init(
        isExpanded: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.isExpanded = isExpanded
        self.content = content
        self.label = label
    }

    init(
        _ key: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(content: content) {
            Text(key)
        }
    }

    init(
        @ViewBuilder content: @escaping () -> Content
    ) where Label == EmptyView {
        self.init(content: content) {
            EmptyView()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if Label.self != EmptyView.self {
                HStack(spacing: 0) {
                    AliveButton {
                        withAnimation(animation) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemSymbol: .chevronDown)
                                .aspectRatio(1 / 1, contentMode: .fit)
                                .rotationEffect(isExpanded ? .zero : .degrees(-90), anchor: .center)

                            label()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }

            if isExpanded {
                Group {
                    content()
                }
                .transition(.blurReplace)
            }
        }
    }
}

#Preview {
    LabeledSection {
        Text("Content")
        Button("Button") {}
    } label: {
        Text("Label")
    }
    .padding()
}
