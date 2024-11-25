//
//  WindowAccessor.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
