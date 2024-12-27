//
//  Text+Extensions.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/25.
//

import SwiftUI

extension Text.Layout {
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }

    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        flatMap(\.self)
    }
}
