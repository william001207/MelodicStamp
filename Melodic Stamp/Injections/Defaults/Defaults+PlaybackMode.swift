//
//  Defaults+PlaybackMode.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import Foundation

extension Defaults {
    typealias PlaybackMode = MelodicStamp.PlaybackMode
}

extension Defaults.PlaybackMode: Defaults.Serializable {}
