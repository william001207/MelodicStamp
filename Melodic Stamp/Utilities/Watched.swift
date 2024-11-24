//
//  Watched.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

@propertyWrapper struct Watched<V>: DynamicProperty where V: Equatable {
    @State private var internalValue: V
    @State private var initialValue: V
    
    init(wrappedValue: V) {
        self.internalValue = wrappedValue
        self.initialValue = wrappedValue
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
        internalValue = value
        initialValue = value
    }
    
    func revert() {
        internalValue = initialValue
    }
}
