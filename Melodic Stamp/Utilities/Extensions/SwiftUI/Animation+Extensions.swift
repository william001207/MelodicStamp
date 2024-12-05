//
//  Animation+Extensions.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI

extension Animation {
    static var instant = Self.linear(duration: 0)
}

extension Animation {
    func `repeat`(while condition: Bool, autoreverses: Bool = true) -> Animation {
        if condition {
            repeatForever(autoreverses: autoreverses)
        } else {
            self
        }
    }
}
