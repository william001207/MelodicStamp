//
//  Device.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Foundation
import SFSafeSymbols

protocol Device: Identifiable {
    var name: String { get }
    var symbol: SFSymbol { get }
}
