//
//  ThumbnailMaker.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/11.
//

import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import CSFBAudioEngine

enum ThumbnailMaker {
    static func make(_ image: NSImage, resolution: CGFloat = 128) -> NSImage? {
        guard
            let tiffData = image.tiffRepresentation,
            let ciImage = CIImage(data: tiffData)
        else {
            return nil
        }

        // Calculate and create the scaled image
        let scale = min(
            resolution / ciImage.extent.width,
            resolution / ciImage.extent.height, 1
        )
        let scaledSize = CGSize(
            width: ciImage.extent.width * scale,
            height: ciImage.extent.height * scale
        )
        let scaledCIImage = ciImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale))

        // Create the context
        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false,
            .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
            .workingColorSpace: CGColorSpaceCreateDeviceRGB()
        ]
        let ciContext = CIContext(options: options)

        // Apply filters
        let sharpnessFilter = CIFilter.sharpenLuminance()
        sharpnessFilter.inputImage = scaledCIImage
        sharpnessFilter.sharpness = 1
        let sharpenedImage = sharpnessFilter.outputImage

        // Find the result
        let resultImage = sharpenedImage ?? scaledCIImage
        guard
            let cgImage = ciContext.createCGImage(
                resultImage, from: resultImage.extent
            )
        else {
            return nil
        }

        let resizedNSImage = NSImage(cgImage: cgImage, size: scaledSize)
        return resizedNSImage
    }

    static func getCover(from attachedPictures: Set<AttachedPicture>)
        -> AttachedPicture? {
        guard !attachedPictures.isEmpty else { return nil }

        let preferredTypes: [AttachedPicture.`Type`] = [
            .frontCover, .backCover,
            .illustration, .fileIcon, .otherFileIcon,
            .leafletPage, .media
        ]
        let preferredAttachedPicture =
            preferredTypes
                .compactMap { getCover(of: $0, from: attachedPictures) }
                .first
        return preferredAttachedPicture ?? attachedPictures.first
    }

    static func getCover(
        of type: AttachedPicture.`Type`,
        from attachedPictures: Set<AttachedPicture>
    ) -> AttachedPicture? {
        attachedPictures.first { $0.type == type }
    }
}
