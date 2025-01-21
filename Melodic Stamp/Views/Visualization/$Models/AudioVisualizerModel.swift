//
//  AudioVisualizerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CSFBAudioEngine
import Foundation

@Observable final class AudioVisualizerModel {
    var analyzer: RealtimeAnalyzer = .init(fftSize: Int(PlayerModel.bufferSize))

    private(set) var data: [[Float]] = [[]]
    private(set) var normalizedData: [[Float]] = [[]]
    private(set) var average: Float = 0.5

    func updateData(from buffer: AVAudioPCMBuffer) {
        data = analyzer.analyze(with: buffer)
        normalizedData = data.map(\.normalized)
        average = normalizedData.flatMap(\.self).reduce(0, +) / Float(normalizedData.count)
    }
}
