//
//  ContinuousRipple.metal
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/3.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]] half4 w(float2 p, SwiftUI::Layer a, float2 l, float2 v) {
    // Compute the motion vector with a falloff based on distance
    float2 m = -v * pow(clamp(1 - length(l - p) / 190, 0.0, 1.0), 2) * 1.5;
    
    half3 c = 0; // Initialize the color accumulator to zero
    
    // Loop to sample colors and accumulate
    for (float i = 0; i < 10; i++) {
        float s = 0.175 + 0.005 * i; // Increasing spread factor
        
        // Accumulate sampled colors from texture a at various offsets
        c += half3(
            a.sample(p + s * m).r,
            a.sample(p + (s + 0.025) * m).g,
            a.sample(p + (s + 0.05) * m).b
        );
    }
    
    // Return the average of the sampled colors with an alpha of 1
    return half4(c / 10, 1);
}
