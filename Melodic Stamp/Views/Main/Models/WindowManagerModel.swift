//
//  WindowManagerModel.swift
//  Melodic Stamp
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
}

@Observable final class WindowManagerModel {
    var style: MelodicStampWindowStyle = .main
}
