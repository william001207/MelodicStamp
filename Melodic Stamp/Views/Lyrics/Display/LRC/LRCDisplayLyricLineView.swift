//
//  LRCDisplayLyricLineView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import Defaults
import SwiftUI

struct LRCDisplayLyricLineView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @Default(.lyricsAttachments) private var attachments

    var line: LRCLyricLine
    var isHighlighted: Bool = false
    var inactiveOpacity: Double = 0.55

    var body: some View {
        VStack(spacing: 5) {
            Group {
                Text(line.content)
                    .font(.system(size: 24 * dynamicTypeSize.scale))
                    .opacity(isHighlighted ? 1.0 : inactiveOpacity)

                if attachments.contains(.translation), let translation = line.translation {
                    Text(translation)
                        .font(.system(size: 14 * dynamicTypeSize.scale))
                        .opacity(isHighlighted ? 0.75 : inactiveOpacity)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .bold()
        }
    }
}
