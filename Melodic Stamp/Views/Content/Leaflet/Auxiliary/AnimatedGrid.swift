//
//  AnimatedGrid.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/26.
//

// TODO: Add an effect that shakes along with the music.
import SwiftUI
import MeshGradient
import MeshGradientCHeaders

struct AnimatedGrid: View {
    
    typealias MeshColor = SIMD3<Float>
    
    var CoverColors: [Color]
    
    var GridColors: [simd_float3] {
        return CoverColors.map { $0.toSimdFloat3() }
    }
         
    var meshRandomizer = MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: meshColors))
    
    var body: some View {
        
        MeshGradient(
            initialGrid: generatePlainGrid(),
            animatorConfiguration: .init(
                animationSpeedRange: 4 ... 5,
                meshRandomizer:
                    MeshRandomizer(
                        colorRandomizer:
                            MeshRandomizer.arrayBasedColorRandomizer(
                                availableColors: GridColors
                            )
                    )
            )
        )
    }
    
    func generatePlainGrid(size: Int = 4) -> MeshGradientGrid<ControlPoint> {
        
        let preparationGrid = MeshGradientGrid<MeshColor>(repeating: .zero, width: size, height: size)
        var result = MeshGenerator.generate(colorDistribution: preparationGrid)
        
        for x in stride(from: 0, to: result.width, by: 1) {
            for y in stride(from: 0, to: result.height, by: 1) {
                meshRandomizer.locationRandomizer(&result[x, y].location, x, y, result.width, result.height)
                meshRandomizer.turbulencyRandomizer(&result[x, y].uTangent, x, y, result.width, result.height)
                meshRandomizer.turbulencyRandomizer(&result[x, y].vTangent, x, y, result.width, result.height)
                meshRandomizer.colorRandomizer(&result[x, y].color, result[x, y].color, x, y, result.width, result.height)
            }
        }
        return result
    }
}

private var meshColors: [simd_float3] {
    return [
        Color(hex: 0x808080).toSimdFloat3(),
        Color(hex: 0x808080).toSimdFloat3(),
        Color(hex: 0x808080).toSimdFloat3()
    ]
}
