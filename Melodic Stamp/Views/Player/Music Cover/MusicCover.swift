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

    var hasMotion: Bool = false

    var body: some View {
        if !images.isEmpty {
            // TODO: Handle multiple images
            if hasMotion {
                imageView(images.first!)
                    .motionCard(
                        scale: 1.02,
                        angle: .degrees(3.5),
                        shadowColor: .black.opacity(0.1),
                        shadowRadius: 10
                    )
            } else {
                imageView(images.first!)
            }
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

    @ViewBuilder private func imageView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}

#if DEBUG
    #Preview {
        MusicCover(images: [.templateArtwork], cornerRadius: 12, hasMotion: true)
            .scaleEffect(0.85, anchor: .center)
            .padding()
    }
#endif
