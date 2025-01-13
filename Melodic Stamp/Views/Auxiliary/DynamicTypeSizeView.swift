//
//  DynamicTypeSizeView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import SwiftUI

struct DynamicTypeSizeView: View {
    var typeSize: DynamicTypeSize
    
    var body: some View {
        switch typeSize {
        case .xSmall: Text("Extra Small")
        case .small: Text("Small")
        case .medium: Text("Medium")
        case .large: Text("Large")
        case .xLarge: Text("Extra Large")
        case .xxLarge: Text("Extra² Large")
        case .xxxLarge: Text("Extra³ Large")
        case .accessibility1: Text("Accessibility 1")
        case .accessibility2: Text("Accessibility 2")
        case .accessibility3: Text("Accessibility 3")
        case .accessibility4: Text("Accessibility 4")
        case .accessibility5: Text("Accessibility 5")
        @unknown default: Text("Unknown")
        }
    }
}

#Preview {
    DynamicTypeSizeView(typeSize: .large)
}
