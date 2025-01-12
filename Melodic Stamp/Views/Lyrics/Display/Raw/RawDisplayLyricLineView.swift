//
//  RawDisplayLyricLineView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct RawDisplayLyricLineView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var line: RawLyricLine

    var body: some View {
        Text(line.content)
            .font(.system(size: 24 * dynamicTypeSize.scale))
            .bold()
    }
}
