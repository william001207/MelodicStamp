//
//  LabeledSection.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct LabeledSection<Content, Label>: View where Content: View, Label: View {
    @ViewBuilder private var content: () -> Content
    @ViewBuilder private var label: () -> Label
    
    init(
        content: @escaping () -> Content,
        label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
    }
    
    init(
        _ key: LocalizedStringKey,
        content: @escaping () -> Content
    ) where Label == Text {
        self.init(content: content) {
            Text(key)
        }
    }
    
    init(
        content: @escaping () -> Content
    ) where Label == EmptyView {
        self.init(content: content) {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if Label.self != EmptyView.self {
                HStack(spacing: 0) {
                    label()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            
            content()
        }
    }
}

#Preview {
    LabeledSection {
        Button("Button") {
            
        }
    } label: {
        Text("Label")
    }
    .padding()
}
