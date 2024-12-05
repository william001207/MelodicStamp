//
//  EnvironmentValues.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var melodicStampWindowStyle: MelodicStampWindowStyle = .main
    @Entry var changeMelodicStampWindowStyle: (MelodicStampWindowStyle) -> () = { _ in }
}
