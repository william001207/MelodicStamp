//
//  AnimatedGrid.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

import MeshGradient
import MeshGradientCHeaders
import SwiftUI

typealias Color3 = simd_float3

extension Color3 {
    static func lerp(_ a: Color3, _ b: Color3, _ t: Float) -> Color3 {
        return a + (b - a) * t
    }
}

struct AnimatedGrid: View {
    
    @Environment(PlayerModel.self) private var player
    
    @State private var gradientSpeed: Float = 0.5
    
    @State private var maxHistory: [CGFloat] = []
    @State private var minHistory: [CGFloat] = []
    
    private let historyWindowSize = 10

    private var colors: [Color]

    private var simdColors: [simd_float3] {
        colors.map { $0.toSimdFloat3() }
    }
    
    let colorA: simd_float3
    let colorB: simd_float3
    let colorC: simd_float3

    init(colors: [Color]) {
        self.colors = colors

        let simdColors = colors.map { $0.toSimdFloat3() }
        self.colorA = simdColors.indices.contains(0) ? simdColors[0] : simd_float3(0, 0, 0)
        self.colorB = simdColors.indices.contains(1) ? simdColors[1] : simd_float3(0, 0, 0)
        self.colorC = simdColors.indices.contains(2) ? simdColors[2] : simd_float3(0, 0, 0)
    }
    
    private var randomizer: MeshRandomizer {
        MeshRandomizer(colorRandomizer: { color, initialColor, x, y, gridWidth, gridHeight in
            // 计算 normalized position
            let normalizedX = Float(x) / Float(gridWidth - 1)
            let normalizedY = Float(y) / Float(gridHeight - 1)
            
            let baseWeight = (normalizedX + normalizedY) / 1.2
            
            let adjustedWeight = baseWeight * gradientSpeed
            
            let colorAB = Color3.lerp(colorA, colorB, adjustedWeight)
            let colorBC = Color3.lerp(colorB, colorC, adjustedWeight)
            let colorCA = Color3.lerp(colorC, colorA, adjustedWeight)
            
            let sumColor = [colorA, colorAB, colorB, colorBC, colorC, colorCA]
            
            let index = (x + y) % sumColor.count
            color = sumColor[index]
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
        .onReceive(player.visualizationDataPublisher) { fftData in
            let (normalizedData, newMax, newMin) = normalizeData(fftData: fftData, maxHistory: maxHistory, minHistory: minHistory)
            gradientSpeed = Float(normalizedData)
            updateHistory(max: newMax, min: newMin)
        }
    }
    
    private func normalizeData(fftData: [CGFloat], maxHistory: [CGFloat], minHistory: [CGFloat]) -> (CGFloat, CGFloat, CGFloat) {
        
        let validFFTData = fftData.filter { $0.isFinite }
        let validMaxHistory = maxHistory.filter { $0.isFinite }
        let validMinHistory = minHistory.filter { $0.isFinite }

        let currentMax = validFFTData.max() ?? 0
        let currentMin = validFFTData.min() ?? 0
        let dynamicMax = max((validMaxHistory + [currentMax]).max() ?? 0, 1e-6)
        let dynamicMin = min((validMinHistory + [currentMin]).min() ?? 0, dynamicMax - 1e-6)

        if !dynamicMin.isFinite || !dynamicMax.isFinite || dynamicMax <= dynamicMin {
            return (0.5, 1e-6, 0)
        }

        let fftPeak = validFFTData.max() ?? 0

        let normalizedValue = (fftPeak - dynamicMin) / (dynamicMax - dynamicMin)

        if normalizedValue.isNaN {
            return (0.5, dynamicMax, dynamicMin)
        }

        return (normalizedValue, currentMax, currentMin)
    }
    
    private func updateHistory(max: CGFloat, min: CGFloat) {
        
        guard historyWindowSize > 0 else { return }

        if maxHistory.count >= historyWindowSize {
            maxHistory.removeFirst()
        }
        if minHistory.count >= historyWindowSize {
            minHistory.removeFirst()
        }

        maxHistory.append(max)
        minHistory.append(min)
    }

    private func generatePlainGrid(size: Int = 4) -> MeshGradientGrid<ControlPoint> {
        let preparationGrid = MeshGradientGrid<Color3>(repeating: .zero, width: size, height: size)
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
