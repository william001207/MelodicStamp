//
//  AnimatedGrid.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import MeshGradient
import MeshGradientCHeaders
import SwiftUI

struct AnimatedGrid: View {
    typealias MeshColor = SIMD3<Float>

    @Environment(PlayerModel.self) private var player
    @State var gradientStep: CGFloat = 1.0

    var colors: [Color]

    private var simdColors: [simd_float3] {
        colors.map { $0.toSimdFloat3() }
    }

    private var randomizer: MeshRandomizer {
        MeshRandomizer(
            colorRandomizer: fastColorTransitionRandomizer(
                availableColors: dynamicGridColors(
                    startColor: simdColors[0],
                    middleColor: simdColors[1],
                    endColor: simdColors[2]
                )
            )
        )
    }

    var body: some View {
        VStack {
            MeshGradient(
                initialGrid: generatePlainGrid(),
                animatorConfiguration: .init(
                    framesPerSecond: 120,
                    locationAnimationSpeedRange: 4...5,
                    tangentAnimationSpeedRange: 4...5,
                    colorAnimationSpeedRange: 0.1...0.2,
                    meshRandomizer: randomizer
                ),
                grainAlpha: 0,
                resolutionScale: 0.8
            )
        }
        .onReceive(player.visualizationDataPublisher) { _ in
        }
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

    func generateThreeColorGradientColors(
        from startColor: simd_float3,
        through middleColor: simd_float3,
        to endColor: simd_float3,
        gradientSteps: [Float]
    ) -> [simd_float3] {
        let midIndex = gradientSteps.count / 2
        let firstHalfSteps = Array(gradientSteps[0 ..< midIndex])
        let secondHalfSteps = Array(gradientSteps[midIndex...])

        let firstGradient = firstHalfSteps.map { step in
            startColor + (middleColor - startColor) * step
        }

        let secondGradient = secondHalfSteps.map { step in
            middleColor + (endColor - middleColor) * step
        }

        return firstGradient + secondGradient
    }

    func dynamicGridColors(startColor: simd_float3, middleColor: simd_float3, endColor: simd_float3) -> [simd_float3] {
        let gradientSteps = generateDynamicGradientSteps(maxStep: Float(gradientStep))

        return generateThreeColorGradientColors(
            from: startColor,
            through: middleColor,
            to: endColor,
            gradientSteps: gradientSteps
        )
    }

    func generateDynamicGradientSteps(maxStep: Float) -> [Float] {
        let baseSteps: [Float] = [1.0, 0.35, 0.35, 1.0, 0.35, 0.35, 1.0]
        return baseSteps.map { $0 * maxStep }
    }

    func fastColorTransitionRandomizer(availableColors: [simd_float3]) -> MeshRandomizer.ColorRandomizer {
        { color, _, x, y, _, _ in
            let index = (x + y) % availableColors.count
            color = availableColors[index]
        }
    }
}
