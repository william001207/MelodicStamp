//
//  Checkpoint.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/18.
//

import SwiftUI

enum Checkpoint<V> {
    case invalid
    case valid(value: V)

    mutating func set(_ newValue: V) {
        self = .valid(value: newValue)
    }
}
