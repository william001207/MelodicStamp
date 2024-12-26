//
//  Color+Extensions.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import SwiftUI
import simd

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Color {
    func toSimdFloat3() -> simd_float3 {
        let nsColor = NSColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return simd_float3(Float(red), Float(green), Float(blue))
    }
}
