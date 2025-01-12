//
//  Defaults+LyricAttachments.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import Foundation

extension Defaults {
    typealias LyricAttachments = MelodicStamp.LyricAttachments
}

extension Defaults.LyricAttachments: Defaults.Serializable {}
