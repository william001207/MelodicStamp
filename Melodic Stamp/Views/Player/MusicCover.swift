//
//  MusicCover.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct MusicCover: View {
    var cornerRadius: CGFloat = 8
    var coverImages: Set<NSImage>
    
    var body: some View {
        Group {
            if let image = coverImages.first {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
