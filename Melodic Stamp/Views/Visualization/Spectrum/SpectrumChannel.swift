//
//  SpectrumChannel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/21.
//

import SwiftUI

struct SpectrumChannel: View {
    var spectra: [Float]
    var barWidth: CGFloat
    var space: CGFloat
    var bounds: CGSize

    private let topSpace: CGFloat = 0.0
    private let bottomSpace: CGFloat = 0.0

    var body: some View {
        Path { path in
            for (i, amplitude) in spectra.enumerated() {
                let x = CGFloat(i) * (barWidth + space) + space
                let y = translateAmplitudeToYPosition(amplitude: amplitude, bounds: bounds)
                let barHeight = bounds.height - y - bottomSpace
                let bar = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                path.addRect(bar)
            }
        }
        .frame(width: bounds.width, height: bounds.height)
    }

    private func translateAmplitudeToYPosition(amplitude: Float, bounds: CGSize) -> CGFloat {
        let barHeight = CGFloat(amplitude) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
}
