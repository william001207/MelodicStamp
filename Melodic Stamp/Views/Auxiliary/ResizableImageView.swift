//
//  ResizableImageView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ResizableImageView: View {
    static let gradation: CGFloat = 32

    var image: NSImage
    var maxResolution: CGFloat? = 128

    @State private var resizedImage: NSImage?

    private let context = CIContext()

    var body: some View {
        Group {
            if let resizedImage {
                Image(nsImage: resizedImage)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .task {
                        await generateThumbnail()
                    }
            }
        }
        .onChange(of: image) { oldImage, newImage in
            guard
                newImage.tiffRepresentation.hashValue
                    != oldImage.tiffRepresentation.hashValue
            else { return }

            Task {
                await generateThumbnail()
            }
        }
    }

    private var resolution: CGFloat? {
        guard let maxResolution else { return nil }
        return floor(maxResolution / Self.gradation) * Self.gradation
    }

    private func generateThumbnail() async {
        guard let resolution else { return }

        if let resized = await resize(image: image, resolution: resolution) {
            resizedImage = resized
        }
    }

    private func resize(image: NSImage, resolution: CGFloat) async -> NSImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                guard
                    let tiffData = image.tiffRepresentation,
                    let ciImage = CIImage(data: tiffData)
                else {
                    return continuation.resume(returning: nil)
                }

                let scale = min(
                    resolution / ciImage.extent.width,
                    resolution / ciImage.extent.height, 1)
                let scaledSize = CGSize(
                    width: ciImage.extent.width * scale,
                    height: ciImage.extent.height * scale)

                let scaledCIImage = ciImage.transformed(
                    by: CGAffineTransform(scaleX: scale, y: scale))

                guard
                    let cgImage = self.context.createCGImage(
                        scaledCIImage, from: scaledCIImage.extent)
                else {
                    return continuation.resume(returning: nil)
                }

                let resizedNSImage = NSImage(cgImage: cgImage, size: scaledSize)
                continuation.resume(returning: resizedNSImage)
            }
        }
    }
}
