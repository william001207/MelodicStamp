//
//  AudioVisualizer.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import Combine
import SwiftUI

struct AudioVisualizer: View {
    @Environment(PlayerModel.self) private var player

    let maxMagnitude: CGFloat = 10

    @State private var frequencyData: [[Float]] = []

    var body: some View {
        VStack {
            SpectrumView(spectra: frequencyData)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(player.visualizationDataPublisher) { visualizationData in
            frequencyData = visualizationData
        }
    }
}
