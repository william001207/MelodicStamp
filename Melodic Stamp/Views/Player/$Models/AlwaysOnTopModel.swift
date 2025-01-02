//
//  AlwaysOnTopModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/2.
//

import SwiftUI

@Observable final class AlwaysOnTopModel {
    var isAlwaysOnTop: Bool = true
    var titleVisibility: NSWindow.TitleVisibility = .hidden
    
    func giveUp() {
        isAlwaysOnTop = false
        titleVisibility = .visible
    }
}
