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
