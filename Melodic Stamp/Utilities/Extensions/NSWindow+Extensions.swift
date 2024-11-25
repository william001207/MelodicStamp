//
//  NSWindow+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import Cocoa
import ObjectiveC

extension NSWindow {
    static let swizzleTabbingMode: Void = {
        let originalSelector = #selector(setter: tabbingMode)
        let swizzledSelector = #selector(swizzled_setTabbingMode(_:))
        
        let originalMethod = class_getInstanceMethod(NSWindow.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(NSWindow.self, swizzledSelector)
        
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @objc private func swizzled_setTabbingMode(_ newValue: NSWindow.TabbingMode) {
        // call the original implementation (swizzled with the original setter)
        swizzled_setTabbingMode(newValue)
        
        // observe the change
        print("Tabbing mode changed to: \(newValue)")
    }
}

// activate swizzling
let _nsWindowSwizzleTabbingMode: Void = NSWindow.swizzleTabbingMode
