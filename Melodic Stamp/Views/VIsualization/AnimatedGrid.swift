//
//  AnimatedGrid.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import MeshGradient
import MeshGradientCHeaders

// TODO: Add an effect that shakes along with the music
import SwiftUI

struct AnimatedGrid: View {
    typealias MeshColor = SIMD3<Float>

    var colors: [Color]

    var body: some View {
        MeshGradient(
            initialGrid: generatePlainGrid(),
            animatorConfiguration: .init(
                animationSpeedRange: 4...5,
                meshRandomizer: randomizer
            )
        )
    }

    private var simdColors: [simd_float3] {
        colors.map { $0.toSimdFloat3() }
    }

    private var randomizer: MeshRandomizer {
        MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: simdColors))
    }

    private func generatePlainGrid(size: Int = 4) -> MeshGradientGrid<ControlPoint> {
        let preparationGrid = MeshGradientGrid<MeshColor>(repeating: .zero, width: size, height: size)
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
