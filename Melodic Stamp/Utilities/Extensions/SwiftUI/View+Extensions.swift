//
//  View+Extensions.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI

extension View {
    func observeAnimation<Value: VectorArithmetic>(for observedValue: Value, onChange: ((Value) -> ())? = nil, onComplete: (() -> ())? = nil) -> some View {
        modifier(AnimationObserverModifier(for: observedValue, onChange: onChange, onComplete: onComplete))
    }

    @ViewBuilder func fakeProgressiveBlur(
        startPoint: UnitPoint, endPoint: UnitPoint, isActive: Bool = true
    ) -> some View {
        if isActive {
            modifier(FakeProgressiveBlurViewModifier(startPoint: startPoint, endPoint: endPoint))
        } else {
            self
        }
    }
}
