//
//  Watched.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

@propertyWrapper struct Watched<V>: DynamicProperty where V: Equatable {
    @State private(set) var internalValue: V
    @State private(set) var initialValue: V
    
    init(_ wrappedValue: V, initialValue: V) {
        self.internalValue = wrappedValue
        self.initialValue = initialValue
    }
    
    init(wrappedValue: V) {
        self.init(wrappedValue, initialValue: wrappedValue)
    }
    
    var wrappedValue: V {
        get {
            internalValue
        }
        
        nonmutating set {
            internalValue = newValue
        }
    }
    
    var projectedValue: Binding<V> {
        Binding(
            get: { internalValue },
            set: { newValue in
                wrappedValue = newValue
            }
        )
    }
    
    var isModified: Bool {
        internalValue != initialValue
    }
    
    func reinit() {
        initialValue = internalValue
    }
    
    func reinit(with value: V) {
        reinit(with: value, initialValue: value)
    }
    
    func reinit(with value: V, initialValue: V) {
        self.internalValue = value
        self.initialValue = initialValue
    }
    
    func revert() {
        internalValue = initialValue
    }
}
