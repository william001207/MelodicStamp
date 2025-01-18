//
//  CreationParameters.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Foundation

struct CreationParameters: Hashable, Codable {
    var urls: Set<URL> = []
    var shouldPlay: Bool = false
    var initialWindowStyle: MelodicStampWindowStyle = .main
}
