//
//  AnimatedGrid.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

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
    @Environment(VisualizerModel.self) private var visualizer

    var colors: [Color]

    @State private var gradientSpeed: CGFloat = 0.5

    private var randomizer: MeshRandomizer {
        .init(colorRandomizer: { color, _, x, y, gridWidth, gridHeight in
            guard !simdColors.isEmpty else { return }

            let normalizedX = Float(x) / Float(gridWidth - 1)
            let normalizedY = Float(y) / Float(gridHeight - 1)

            let baseWeight = (normalizedX + normalizedY) / 1.2
            let adjustedWeight = baseWeight * Float(gradientSpeed)

            let finalColors = simdColors.blending { first, second in
                SIMDColor.lerp(first, second, factor: adjustedWeight)
            }

            let index = (x + y) % finalColors.count
            color = finalColors[index]
        })
    }

    var body: some View {
        VStack {
            MeshGradient(
                initialGrid: generatePlainGrid(),
                animatorConfiguration: .init(
                    framesPerSecond: 120,
                    locationAnimationSpeedRange: 4...5,
                    tangentAnimationSpeedRange: 4...5,
                    colorAnimationSpeedRange: 0.2...0.25,
                    meshRandomizer: randomizer
                ),
                grainAlpha: 0,
                resolutionScale: 0.8
            )
        }
        .onChange(of: visualizer.normalizedData) { _, newValue in
            gradientSpeed = newValue
        }
    }

    private var simdColors: [SIMDColor] {
        colors.map { $0.toSimdFloat3() }
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
