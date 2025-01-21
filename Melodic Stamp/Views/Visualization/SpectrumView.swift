//
//  SpectrumView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SwiftUI

struct SpectrumView: View {
    var barWidth: CGFloat = 3.0
    var space: CGFloat = 1.0
    var spectra: [[Float]]?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let leftSpectra = spectra?.first {
                    SpectrumChannelView(spectra: leftSpectra, barWidth: barWidth, space: space, bounds: geometry.size, isLeft: true)
                }

                if let rightSpectra = spectra?.last {
                    SpectrumChannelView(spectra: rightSpectra, barWidth: barWidth, space: space, bounds: geometry.size, isLeft: false)
                }
            }
        }
        .frame(height: 100)
    }
}

struct SpectrumChannelView: View {
    var spectra: [Float]
    var barWidth: CGFloat
    var space: CGFloat
    var bounds: CGSize
    var isLeft: Bool

    private let topSpace: CGFloat = 0.0
    private let bottomSpace: CGFloat = 0.0

    var body: some View {
        let gradientColors: [Color]

            // Set gradient colors and direction based on left or right channel
            = if isLeft {
            [Color.red, Color.yellow]
        } else {
            [Color.green, Color.blue]
        }

        return Path { path in
            for (i, amplitude) in spectra.enumerated() {
                let x = CGFloat(i) * (barWidth + space) + space
                let y = translateAmplitudeToYPosition(amplitude: amplitude, bounds: bounds)
                let barHeight = bounds.height - y - bottomSpace
                let bar = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                path.addRect(bar)
            }
        }
        .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom))
        .frame(width: bounds.width, height: bounds.height)
    }

    private func translateAmplitudeToYPosition(amplitude: Float, bounds: CGSize) -> CGFloat {
        let barHeight = CGFloat(amplitude) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
}

#Preview {
    SpectrumView(spectra: [
        [0.1, 0.3, 0.5, 0.7, 0.9],
        [0.9, 0.7, 0.5, 0.3, 0.1]
    ])
}
