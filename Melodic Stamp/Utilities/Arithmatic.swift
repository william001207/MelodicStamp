//
//  Arithmatic.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/30.
//

import Foundation

func lerp<Value>(_ a: Value, _ b: Value, factor t: Double) -> Value where Value: BinaryFloatingPoint {
    let t = min(max(t, 0), 1)
    return a + (b - a) * Value(t)
}
