//
//  SpectrumMiniView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SwiftUI

struct SpectrumMiniView: View {
    var spectra: [[Float]]?

    var barWidth: CGFloat = 2.0
    var space: CGFloat = 2.0
    private let bottomSpace: CGFloat = 0.0
    private let topSpace: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geometry in
                HStack(spacing: space) {
                    if let leftSpectra = spectra?.first {
                        let sortedLeft = leftSpectra.sorted()
                        HStack(spacing: space) {
                            ForEach(0 ..< 3, id: \.self) { index in
                                let amplitude = averageAmplitude(for: sortedLeft, index: index, totalBars: 3)
                                SpectrumBar(amplitude: amplitude, bounds: geometry.size)
                                    .frame(width: barWidth)
                            }
                        }
                    }
                    if let rightSpectra = spectra?.last {
                        let sortedRight = Array(rightSpectra.sorted().reversed())
                        HStack(spacing: space) {
                            ForEach(0 ..< 3, id: \.self) { index in
                                let amplitude = averageAmplitude(for: sortedRight, index: index, totalBars: 3)
                                SpectrumBar(amplitude: amplitude, bounds: geometry.size)
                                    .frame(width: barWidth)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }

    private func averageAmplitude(for channel: [Float], index: Int, totalBars: Int) -> Float {
        let segmentLength = channel.count / totalBars
        let start = segmentLength * index
        let end = min(start + segmentLength, channel.count)
        let segment = channel[start ..< end]

        let sum = segment.reduce(0, +)
        let average = sum / Float(segment.count)

        let adjustedHeight = average * 5.0
        return adjustedHeight
    }
}

struct SpectrumBar: View {
    var amplitude: Float
    var bounds: CGSize

    var body: some View {
        VStack {
            let barHeight = translateAmplitudeToYPosition(amplitude: amplitude, bounds: bounds)

            Rectangle()
                .fill(Color.black.opacity(0.45))
                .frame(height: barHeight)
                .cornerRadius(8)
                .animation(.easeInOut(duration: 0.15), value: barHeight)
        }
    }

    private func translateAmplitudeToYPosition(amplitude: Float, bounds: CGSize) -> CGFloat {
        let maxHeight = bounds.height
        let calculatedHeight = CGFloat(amplitude) * maxHeight

        return min(max(calculatedHeight, 2), 20)
    }
}

#Preview {
    VStack {
        SpectrumMiniView(spectra: [
            [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.5, 0.8, 0.3, 0.6],
            [0.9, 0.7, 0.5, 0.3, 0.1, 0.8, 0.6, 0.4, 0.2, 0.5]
        ])
        .frame(width: 20, height: 20)
    }
    .background(Color.white)
}
