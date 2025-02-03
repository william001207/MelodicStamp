//
//  Binding+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

extension Binding {
    init?(unwrapping binding: Binding<Value?>) {
        if let value = binding.wrappedValue {
            self.init {
                value
            } set: { newValue in
                binding.wrappedValue = newValue
            }
        } else {
            return nil
        }
    }
}

extension Binding {
    static prefix func ~ (binding: Binding<Value?>) -> Binding<Value>? {
        .init(unwrapping: binding)
    }
}

extension Binding {
    static func convert<TInt, TFloat>(_ intBinding: Binding<TInt>) -> Binding<TFloat> where TInt: BinaryInteger, TFloat: BinaryFloatingPoint {
        Binding<TFloat> {
            TFloat(intBinding.wrappedValue)
        } set: { newValue in
            intBinding.wrappedValue = TInt(newValue)
        }
    }

    static func convert<TFloat, TInt>(_ floatBinding: Binding<TFloat>) -> Binding<TInt> where TFloat: BinaryFloatingPoint, TInt: BinaryInteger {
        Binding<TInt> {
            TInt(floatBinding.wrappedValue)
        } set: { newValue in
            floatBinding.wrappedValue = TFloat(newValue)
        }
    }
}
