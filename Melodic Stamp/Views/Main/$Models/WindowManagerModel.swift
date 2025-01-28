//
//  WindowManagerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

enum MelodicStampWindowStyle: String, Equatable, Hashable, CaseIterable, Identifiable, Codable {
    case main
    case miniPlayer

    var id: Self {
        self
    }
}

@Observable final class WindowManagerModel {
    var style: MelodicStampWindowStyle {
        didSet {
            switch style {
            case .main:
                isAlwaysOnTop = false
            case .miniPlayer:
                isAlwaysOnTop = true
            }
        }
    }

    var isInitialized: Bool = false
    var isAlwaysOnTop: Bool = false
    private(set) var isInFullScreen: Bool = false

    init(style: MelodicStampWindowStyle = .main) {
        self.style = style
    }

    func observe(_ window: NSWindow? = nil) {
        NotificationCenter.default.removeObserver(self)
        guard let window else { return }

        isInFullScreen = window.isInFullScreen

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidEnterFullScreen),
            name: NSWindow.didEnterFullScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidExitFullScreen),
            name: NSWindow.didExitFullScreenNotification,
            object: window
        )
    }
}

extension WindowManagerModel {
    @objc func windowDidEnterFullScreen() {
        isInFullScreen = true
    }

    @objc func windowDidExitFullScreen() {
        isInFullScreen = false
    }
}
