//
//  AudioVisualizer.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import SwiftUI
import Combine

struct AudioVisualizer: View {
    @Environment(PlayerModel.self) private var player

    let maxMagnitude: CGFloat = 10
    
    @State private var frequencyData: [CGFloat] = Array(repeating: 0, count: 5)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(frequencyData, id: \.self) { magnitude in
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
            frequencyData = sampleData(visualizationData, count: 5)
        }
    }

    private func sampleData(_ data: [CGFloat], count: Int) -> [CGFloat] {
        guard !data.isEmpty else { return .init(repeating: 0, count: count) }
        
        let chunkSize = max(data.count / count, 1)
        return stride(from: 0, to: data.count, by: chunkSize).map {
            Array(data[$0..<min($0 + chunkSize, data.count)]).reduce(0, +) / CGFloat(chunkSize)
        }
    }
}

