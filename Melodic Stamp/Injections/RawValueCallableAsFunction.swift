//
//  RawValueCallableAsFunction.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/2/1.
//

import Foundation

protocol RawValueCallableAsFunction: RawRepresentable {
    func callAsFunction() -> RawValue
}

extension RawValueCallableAsFunction {
    func callAsFunction() -> RawValue {
        rawValue
    }
}
