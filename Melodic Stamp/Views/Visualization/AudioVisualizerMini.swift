//
//  AudioVisualizerMini.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import Combine
import SwiftUI

struct AudioVisualizerMini: View {
    @Environment(PlayerModel.self) private var player

    let maxMagnitude: CGFloat = 10

    @State private var frequencyData: [[Float]] = []

    var body: some View {
        VStack(alignment: .center) {
            SpectrumMiniView(spectra: frequencyData)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(width: 20, height: 20, alignment: .center)
        .onReceive(player.visualizationDataPublisher) { visualizationData in
            frequencyData = visualizationData
        }
    }
}
