//
//  AnimationObserver.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//
//  Thanks to https://github.com/kristofkalai/AnimationObserver

import SwiftUI

public struct AnimationObserverModifier<Value: VectorArithmetic> {
    private let observedValue: Value
    private let onChange: ((Value) -> Void)?
    private let onComplete: (() -> Void)?
    
    public var animatableData: Value {
        didSet {
            notifyProgress()
        }
    }
    
    public init(for observedValue: Value, onChange: ((Value) -> Void)? = nil, onComplete: (() -> Void)? = nil) {
        self.observedValue = observedValue
        self.onChange = onChange
        self.onComplete = onComplete
        animatableData = observedValue
    }
}

extension AnimationObserverModifier: AnimatableModifier {
    public func body(content: Content) -> some View {
        content
    }
}

extension AnimationObserverModifier {
    private func notifyProgress() {
        DispatchQueue.main.async {
            onChange?(animatableData)
            if animatableData == observedValue {
                onComplete?()
            }
        }
    }
}
