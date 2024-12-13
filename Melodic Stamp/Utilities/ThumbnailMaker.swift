//
//  ThumbnailMaker.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/11.
//

import CSFBAudioEngine
import SwiftUI

enum ThumbnailMaker {
    static func make(_ image: NSImage, resolution: CGFloat = 64) -> NSImage? {
        guard
            let tiffData = image.tiffRepresentation,
            let ciImage = CIImage(data: tiffData)
        else {
            return nil
        }

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

        guard
            let cgImage = CIContext().createCGImage(
                scaledCIImage, from: scaledCIImage.extent
            )
        else {
            return nil
        }

        let resizedNSImage = NSImage(cgImage: cgImage, size: scaledSize)
        return resizedNSImage
    }

    static func getCover(from attachedPictures: Set<AttachedPicture>) -> AttachedPicture? {
        guard !attachedPictures.isEmpty else { return nil }
        let frontCover = attachedPictures.first { $0.type == .frontCover }
        let backCover = attachedPictures.first { $0.type == .backCover }
        let illustration = attachedPictures.first { $0.type == .illustration }
        let fileIcon = attachedPictures.first { $0.type == .fileIcon }
        return frontCover ?? backCover ?? illustration ?? fileIcon
            ?? attachedPictures.first
    }
}
