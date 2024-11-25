//
//  NSWindowModifier.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct NSWindowModifier: ViewModifier {
    var operation: (NSWindow) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: self.makeTitleBarTransparent)
    }
    
    private func makeTitleBarTransparent() {
        DispatchQueue.main.async {
            if let window = NSApp.mainWindow {
                operation(window)
            }
        }
    }
}
