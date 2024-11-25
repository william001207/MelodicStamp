//
//  ToolbarLabel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct ToolbarLabel<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            content()
        }
        .padding(.horizontal, 2)
    }
}
