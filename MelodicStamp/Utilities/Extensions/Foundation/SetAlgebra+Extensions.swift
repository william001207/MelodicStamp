//
//  SetAlgebra+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Foundation
import SwiftUI

extension SetAlgebra {
    mutating func toggle(_ option: Element) {
        if contains(option) {
            remove(option)
        } else {
            insert(option)
        }
    }
}
