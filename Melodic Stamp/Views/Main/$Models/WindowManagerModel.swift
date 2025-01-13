//
//  WindowManagerModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

enum MelodicStampWindowStyle: String, Equatable, Hashable, Identifiable {
    case main
    case miniPlayer

    var id: Self {
        self
    }

    var hasTitleBar: Bool {
        switch self {
        case .main: true
        case .miniPlayer: false
        }
    }
}

@Observable final class WindowManagerModel {
    var style: MelodicStampWindowStyle = .main {
        didSet {
            switch style {
            case .main:
                giveUpAlwaysOnTop()
            case .miniPlayer:
                setUpAlwaysOnTop()
            }
        }
    }

    var isAlwaysOnTop: Bool = true
    var titleVisibility: NSWindow.TitleVisibility = .hidden

    func setUpAlwaysOnTop() {
        isAlwaysOnTop = true
        titleVisibility = .hidden
    }

    func giveUpAlwaysOnTop() {
        isAlwaysOnTop = false
        titleVisibility = .visible
    }
}
