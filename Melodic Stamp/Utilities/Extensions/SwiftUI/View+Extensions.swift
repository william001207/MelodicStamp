//
//  View+Extensions.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI

extension View {
    func observeAnimation<Value: VectorArithmetic>(for observedValue: Value, onChange: ((Value) -> Void)? = nil, onComplete: (() -> Void)? = nil) -> some View {
        modifier(AnimationObserverModifier(for: observedValue, onChange: onChange, onComplete: onComplete))
    }
    
    @ViewBuilder func fakeProgressiveBlur(
        _ material: NSVisualEffectView.Material = .hudWindow,
        startPoint: UnitPoint, endPoint: UnitPoint
    ) -> some View {
        modifier(FakeProgressiveBlurViewModifier(material: material, startPoint: startPoint, endPoint: endPoint))
    }
}

