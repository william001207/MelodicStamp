//
//  AudioVisualizerView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/22.
//

import SwiftUI

struct AudioVisualizerView: View {
    @Environment(AudioVisualizerModel.self) private var audioVisualizer

    var body: some View {
        VStack(alignment: .center) {
            SpectrumView(spectra: audioVisualizer.normalizedData)
                .animation(.smooth(duration: 0.2), value: audioVisualizer.normalizedData)
        }
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    AudioVisualizerView()
        .frame(width: 20, height: 20)
        .padding()
}
