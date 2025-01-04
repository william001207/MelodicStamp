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
    @State private var gradientStep: CGFloat = 1.0
    @State private var maxHistory: [CGFloat] = []
    @State private var minHistory: [CGFloat] = []
    
    private let historyWindowSize = 10

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
                    colorAnimationSpeedRange: 0.2...0.25,
                    meshRandomizer: randomizer
                ),
                grainAlpha: 0,
                resolutionScale: 0.8
            )
        }
        .onReceive(player.visualizationDataPublisher) { fftData in
            let (normalizedData, newMax, newMin) = normalizeData(fftData: fftData, maxHistory: maxHistory, minHistory: minHistory)
            
            if !newMax.isNaN || !newMin.isNaN || !normalizedData.isNaN {
                gradientStep = normalizedData
                updateHistory(max: newMax, min: newMin)
            }
            
            // print("gradientStep: \(gradientStep), normalizedData: \(normalizedData).")
        }
    }
    
    private func normalizeData(fftData: [CGFloat], maxHistory: [CGFloat], minHistory: [CGFloat]) -> (CGFloat, CGFloat, CGFloat) {
        
        let currentMax = fftData.max() ?? 0
        let currentMin = fftData.min() ?? 0
        let dynamicMax = max((maxHistory + [currentMax]).max() ?? 0, 1e-6)
        let dynamicMin = min((minHistory + [currentMin]).min() ?? 0, dynamicMax - 1e-6)

        if dynamicMax < dynamicMin {
            return (0.6, dynamicMax, dynamicMin)
        }

        let fftPeak = fftData.max() ?? 0

        let baseNormalizedValue = (fftPeak - dynamicMin) / (dynamicMax - dynamicMin)
        let normalizedValue = 0.9 - (baseNormalizedValue * 0.2)

        if normalizedValue.isNaN {
            return (0.6, dynamicMax, dynamicMin)
        }

        return (normalizedValue, currentMax, currentMin)
    }
    
    private func updateHistory(max: CGFloat, min: CGFloat) {
        if maxHistory.count >= historyWindowSize {
            maxHistory.removeFirst()
        }
        if minHistory.count >= historyWindowSize {
            minHistory.removeFirst()
        }
        maxHistory.append(max)
        minHistory.append(min)
    }

    func generatePlainGrid(size: Int = 4) -> MeshGradientGrid<ControlPoint> {
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
