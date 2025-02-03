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
        Text(Self.name(of: typeSize))
    }

    static func name(of typeSize: DynamicTypeSize) -> String {
        switch typeSize {
        case .xSmall:
            String(localized: .init("Dynamic Type Size: X Small", defaultValue: "Extra Small"))
        case .small:
            String(localized: .init("Dynamic Type Size: Small", defaultValue: "Small"))
        case .medium:
            String(localized: .init("Dynamic Type Size: Medium", defaultValue: "Medium"))
        case .large:
            String(localized: .init("Dynamic Type Size: Large", defaultValue: "Large"))
        case .xLarge:
            String(localized: .init("Dynamic Type Size: X Large", defaultValue: "Extra Large"))
        case .xxLarge:
            String(localized: .init("Dynamic Type Size: XX Large", defaultValue: "Extra² Large"))
        case .xxxLarge:
            String(localized: .init("Dynamic Type Size: XXX Large", defaultValue: "Extra³ Large"))
        case .accessibility1:
            String(localized: .init("Dynamic Type Size: Accessibility 1", defaultValue: "Accessibility 1"))
        case .accessibility2:
            String(localized: .init("Dynamic Type Size: Accessibility 2", defaultValue: "Accessibility 2"))
        case .accessibility3:
            String(localized: .init("Dynamic Type Size: Accessibility 3", defaultValue: "Accessibility 3"))
        case .accessibility4:
            String(localized: .init("Dynamic Type Size: Accessibility 4", defaultValue: "Accessibility 4"))
        case .accessibility5:
            String(localized: .init("Dynamic Type Size: Accessibility 5", defaultValue: "Accessibility 5"))
        @unknown default:
            String(localized: .init("Dynamic Type Size: Unknown", defaultValue: "Unknown"))
        }
    }
}

#Preview {
    DynamicTypeSizeView(typeSize: .large)
}
