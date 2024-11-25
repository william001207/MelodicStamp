//
//  ToolbarLabel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct ToolbarLabel<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            content()
        }
        .padding(.horizontal, 2)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.default, value: isEnabled)
    }
}
