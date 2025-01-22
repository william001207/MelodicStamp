//
//  TinyBinaryChannelVisualizerView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/22.
//

import Defaults
import SwiftUI

struct TinyBinaryChannelVisualizerView: View {
    @Environment(AudioVisualizerModel.self) private var audioVisualizer
    @Environment(GradientVisualizerModel.self) private var gradientVisualizer

    @Default(.gradientDynamics) private var gradientDynamics

    var body: some View {
        LinearGradient(
            colors: gradientVisualizer.prefixedDomainantColors(upTo: gradientDynamics.count),
            startPoint: .leading, endPoint: .trailing
        )
        .mask {
            SpectrumView(spectra: audioVisualizer.normalizedData)
                .foregroundStyle(.white)
                .animation(.smooth(duration: 0.2), value: audioVisualizer.normalizedData)
        }
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    TinyBinaryChannelVisualizerView()
        .frame(width: 20, height: 20)
        .padding()
}
