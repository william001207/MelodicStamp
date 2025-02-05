//
//  CatchWindow.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct CatchWindow<Content>: View where Content: View {
    @ViewBuilder var content: (NSWindow?) -> Content

    @State private var window: NSWindow?

    var body: some View {
        content(window)
            .background(MakeCustomizable(customization: { window in
                self.window = window
            }, willAppear: { window in
                self.window = window
            }, didAppear: { window in
                self.window = window
            }))
    }
}
