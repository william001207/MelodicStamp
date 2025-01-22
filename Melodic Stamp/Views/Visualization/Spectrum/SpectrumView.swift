//
//  SpectrumView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SwiftUI

struct SpectrumView: View {
    var spectra: [[Float]]
    var barWidth: CGFloat = 2

    @State private var containerSize: CGSize = .zero

    var body: some View {
        HStack(spacing: 0) {
            if let leftSpectra = spectra.first {
                spectrum(sorted: leftSpectra.sorted())
            }

            if let rightSpectra = spectra.last {
                spectrum(sorted: rightSpectra.sorted().reversed())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            containerSize = newValue
        }
    }

    @ViewBuilder private func spectrum(sorted: [Float]) -> some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 3, id: \.self) { index in
                let amplitude = averageAmplitude(in: sorted, index: index, count: 3)
                bar(amplitude: amplitude)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder private func bar(amplitude: Float) -> some View {
        VStack {
            let height = height(ofAmplitude: amplitude)

            Capsule()
                .fill(Color.primary.opacity(0.3))
                .frame(width: barWidth, height: height)
        }
    }

    private func averageAmplitude(in data: [Float], index: Int, count: Int) -> Float {
        let segmentLength = data.count / count
        let start = segmentLength * index
        let end = min(start + segmentLength, data.count)
        let segment = data[start ..< end]

        let sum = segment.reduce(0, +)
        let average = sum / Float(segment.count)
        return max(0, min(1, average))
    }

    private func height(ofAmplitude amplitude: Float) -> CGFloat {
        max(CGFloat(amplitude) * containerSize.height, barWidth)
    }
}

#Preview {
    SpectrumView(spectra: [
        [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.5, 0.8, 0.3, 0.6],
        [0.9, 0.7, 0.5, 0.3, 0.1, 0.8, 0.6, 0.4, 0.2, 0.5]
    ])
    .border(.blue)
    .frame(width: 100, height: 100)
    .padding()
}
