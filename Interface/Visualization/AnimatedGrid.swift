//
//  AnimatedGrid.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import Defaults
import MeshGradient
import MeshGradientCHeaders
import SwiftUI

typealias SIMDColor = simd_float3

extension SIMDColor {
    static func lerp(_ a: Self, _ b: Self, factor: Float) -> Self {
        a + (b - a) * factor
    }
}

struct AnimatedGrid: View {
    @Environment(PlayerModel.self) private var player
    @Environment(AudioVisualizerModel.self) private var audioVisualizer
    @Environment(GradientVisualizerModel.self) private var gradientVisualizer

    @Default(.gradientDynamics) private var dynamics
    @Default(.gradientAnimateWithAudio) private var animateWithAudio
    @Default(.gradientResolution) private var resolution
    @Default(.gradientFPS) private var fps

    var hasDynamics: Bool = true

    @State private var minAverage: Float = .zero
    @State private var maxAverage: Float = .zero

    private var randomizer: MeshRandomizer {
        .init(
            colorRandomizer: { color, _, x, y, gridWidth, gridHeight in
                guard !simdColors.isEmpty else { return }

                let normalizedX = Float(x) / Float(gridWidth - 1)
                let normalizedY = Float(y) / Float(gridHeight - 1)

                let baseWeight = normalizedX + normalizedY
                let adjustedWeight = baseWeight * weightFactor

                let finalColors = simdColors.blending { first, second in
                    SIMDColor.lerp(first, second, factor: adjustedWeight)
                }

                let index = (x + y) % finalColors.count
                color = finalColors[index]
            }
        )
    }

    var body: some View {
        ZStack {
            switch dynamics {
            case .plain:
                gradientVisualizer.dominantColors.first ?? .clear
            default:
                MeshGradient(
                    initialGrid: generatePlainGrid(),
                    animatorConfiguration: .init(
                        framesPerSecond: Int(fps),
                        locationAnimationSpeedRange: 4...5,
                        tangentAnimationSpeedRange: 4...5,
                        colorAnimationSpeedRange: 0.4...0.41,
                        meshRandomizer: randomizer
                    ),
                    grainAlpha: 0,
                    resolutionScale: Double(resolution)
                )
            }
        }
        .onChange(of: audioVisualizer.average) { _, newValue in
            updateAverage(newValue)
        }
    }

    private var weightFactor: Float {
        if animateWithAudio, hasDynamics, minAverage != maxAverage {
            let average = audioVisualizer.average

            let range = max(maxAverage - minAverage, 0)
            return (average - minAverage) / range
        } else {
            return 0.5
        }
    }

    private var simdColors: [SIMDColor] {
        gradientVisualizer.prefixedDominantColorsWithFallback(upTo: dynamics.count).map { $0.toSimdFloat3() }
    }

    private func updateAverage(_ average: Float) {
        minAverage = min(minAverage, average)
        maxAverage = max(maxAverage, average)
    }

    private func generatePlainGrid(size: Int = 4) -> MeshGradientGrid<ControlPoint> {
        let preparationGrid = MeshGradientGrid<SIMDColor>(repeating: .zero, width: size, height: size)
        var result = MeshGenerator.generate(colorDistribution: preparationGrid)

        for x in stride(from: 0, to: result.width, by: 1) {
            for y in stride(from: 0, to: result.height, by: 1) {
                randomizer.locationRandomizer(&result[x, y].location, x, y, result.width, result.height)
                randomizer.turbulencyRandomizer(&result[x, y].uTangent, x, y, result.width, result.height)
                randomizer.turbulencyRandomizer(&result[x, y].vTangent, x, y, result.width, result.height)
                randomizer.colorRandomizer(&result[x, y].color, result[x, y].color, x, y, result.width, result.height)
            }
        }
        return result
    }
}
