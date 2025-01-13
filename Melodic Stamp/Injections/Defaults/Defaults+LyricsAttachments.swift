//
//  Defaults+LyricsAttachments.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import Foundation

extension Defaults {
    typealias LyricsAttachments = MelodicStamp.LyricsAttachments
}

extension Defaults.LyricsAttachments: Defaults.Serializable {}
