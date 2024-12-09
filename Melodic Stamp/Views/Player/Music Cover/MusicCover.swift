//
//  MusicCover.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import CSFBAudioEngine
import SwiftUI

struct MusicCover: View {
    var cornerRadius: CGFloat = 8
    var images: [NSImage] = []
    var hasPlaceholder: Bool = true
    var maxResolution: CGFloat? = 128
    
    @State private var resizedImages: [NSImage] = []

    var body: some View {
        Group {
            if !images.isEmpty {
                // TODO: handle multiple images
                ResizableImageView(image: images.first!, maxResolution: maxResolution)
            } else {
                Group {
                    if hasPlaceholder {
                        Rectangle()
                            .fill(.regularMaterial)
                            .background(.placeholder.opacity(0.25))
                            .overlay {
                                Image(systemSymbol: .photo)
                                    .imageScale(.large)
                                    .foregroundStyle(.placeholder)
                            }
                    } else {
                        Color.clear
                    }
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
