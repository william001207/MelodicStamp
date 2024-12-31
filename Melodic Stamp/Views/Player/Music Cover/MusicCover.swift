//
//  MusicCover.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import CSFBAudioEngine
import SwiftUI

struct MusicCover: View {
    var images: [NSImage] = []
    var hasPlaceholder: Bool = true
    var cornerRadius: CGFloat = 8

    var body: some View {
        if !images.isEmpty {
            // TODO: Handle multiple images
            image(images.first!)
        } else {
            Group {
                if hasPlaceholder {
                    Rectangle()
                        .foregroundStyle(.placeholder.quinary)
                        .overlay {
                            Image(systemSymbol: .photoOnRectangleAngled)
                                .imageScale(.large)
                                .foregroundStyle(.placeholder)
                        }
                } else {
                    Color.clear
                }
            }
            .aspectRatio(1 / 1, contentMode: .fit)
            .clipShape(.rect(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder private func image(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}

#Preview {
    MusicCover(images: [.templateArtwork], cornerRadius: 12)
        .scaleEffect(0.85, anchor: .center)
}
