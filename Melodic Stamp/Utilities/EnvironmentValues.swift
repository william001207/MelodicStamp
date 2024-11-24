//
//  EnvironmentValues.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

enum MelodicStampWindowStyle: String, Equatable, Hashable, Identifiable {
    case main
    case miniPlayer
    
    var id: Self {
        self
    }
}

extension EnvironmentValues {
    @Entry var melodicStampWindowStyle: MelodicStampWindowStyle = .main
    @Entry var changeMelodicStampWindowStyle: (MelodicStampWindowStyle) -> Void = { _ in }
}
