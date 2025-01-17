//
//  NSWindow+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import AppKit

extension NSWindow {
    var isInFullScreen: Bool {
        styleMask.contains(.fullScreen)
    }
}
