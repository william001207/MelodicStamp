//
//  RawLyrics.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import Foundation

struct RawLyrics: Hashable, Equatable, Identifiable {
    let url: URL
    var content: String?

    var id: URL { url }
}
