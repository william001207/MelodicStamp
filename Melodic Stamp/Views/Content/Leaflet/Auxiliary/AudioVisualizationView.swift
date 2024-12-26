//
//  AudioVisualizationView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import SwiftUI
import Combine

struct AudioVisualizationView: View {
    @Environment(PlayerModel.self) var player

    let maxMagnitude: Float = 10.0
    
    @State private var frequencyData: [Float] = Array(repeating: 0, count: 5)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(frequencyData.indices, id: \.self) { index in
                    let magnitude = frequencyData[index]
                    let normalizedHeight = max(0, CGFloat(magnitude / maxMagnitude) * geometry.size.height)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: (geometry.size.width / 5) - 2, height: normalizedHeight)
                        .cornerRadius(2)
                        .animation(.smooth, value: normalizedHeight)
                }
            }
            .frame(width: 40, height: 40, alignment: .center)
        }
        .onReceive(player.visualizationDataPublisher) { visualizationData in
            
            self.frequencyData = sampleData(visualizationData, count: 5)
            
        }
    }

    private func sampleData(_ data: [Float], count: Int) -> [Float] {
        guard !data.isEmpty else { return Array(repeating: 0, count: count) }
        let chunkSize = max(data.count / count, 1)
        return stride(from: 0, to: data.count, by: chunkSize).map {
            Array(data[$0..<min($0 + chunkSize, data.count)]).reduce(0, +) / Float(chunkSize)
        }
    }
}

