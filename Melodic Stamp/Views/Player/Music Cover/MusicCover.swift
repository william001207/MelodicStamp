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

    var body: some View {
        Group {
            if !images.isEmpty {
                // TODO: handle multiple images
                imageView(images.first!)
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

    @ViewBuilder private func imageView(_ image: NSImage) -> some View {
        let resizedImage = if let maxResolution, let resizedImage = resizeImage(image, maxResolution: maxResolution) {
            resizedImage
        } else {
            image
        }

        Image(nsImage: resizedImage)
            .resizable()
            .interpolation(.medium)
            .aspectRatio(contentMode: .fit)
    }

    private func resizeImage(
        _ image: NSImage,
        maxResolution: CGFloat
    ) -> NSImage? {
        let size = image.size
        let scale = min(
            maxResolution / size.width, maxResolution / size.height, 1
        )
        let newSize = NSSize(
            width: size.width * scale, height: size.height * scale
        )

        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(
            in: .init(origin: .zero, size: newSize),
            from: .init(origin: .zero, size: size),
            operation: .copy,
            fraction: 1.0
        )
        resizedImage.unlockFocus()

        return resizedImage
    }
}
