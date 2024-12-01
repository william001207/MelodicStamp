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
    var maxResolution: CGFloat = 128

    var body: some View {
        Group {
            if let image = coverImages.first,
               let resizedImage = resizeImage(image, maxResolution: maxResolution)
            {
                Image(nsImage: resizedImage)
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
    }

    private func resizeImage(_ image: NSImage, maxResolution: CGFloat) -> NSImage? {
        let size = image.size
        let scale = min(maxResolution / size.width, maxResolution / size.height, 1)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)

        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        resizedImage.unlockFocus()

        return resizedImage
    }
}
