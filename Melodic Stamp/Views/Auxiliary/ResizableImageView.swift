//
//  ResizableImageView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SmartCache
import SwiftUI

struct ResizableImageView: View {
    static let gradation: CGFloat = 32
    static var cache: MemoryCache<URL, Data> = .init(
        maximumCachedValues: 256
    )

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
                // placeholder for displaying this view, otherwise will never get updates
                Color.clear
                    .task(priority: .background) {
                        await getOrGenerateThumbnail()
                    }
            }
        }
        .onChange(of: image) { oldImage, newImage in
            guard newImage.tiffRepresentation != oldImage.tiffRepresentation else { return }
            Task(priority: .background) {
                await getOrGenerateThumbnail()
            }
        }
    }

    private var scaling: Int? {
        guard let maxResolution else { return nil }
        return Int(floor(maxResolution / Self.gradation))
    }

    private var resolution: CGFloat? {
        scaling.map { CGFloat($0) * Self.gradation }
    }

    private func path(of image: NSImage) async -> URL? {
        guard let scaling, let data = image.tiffRepresentation else {
            return nil
        }
        
        let hex = String(UInt(bitPattern: data.hashValue), radix: 16)
        return URL(string: "\(hex)@\(scaling)x")
    }

    private func getOrGenerateThumbnail() async {
        guard let resolution else { return }

        if let path = await path(of: image),
            let cachedImageData = Self.cache.value(forKey: path),
            let cachedImage = NSImage(data: cachedImageData)
        {
            // load from cache
            resizedImage = cachedImage
            print("Loaded thumbnail from cache for \(path)")
        } else if let resizedImage = await resize(
            image: image, resolution: resolution)
        {
            // resize and save to cache
            self.resizedImage = resizedImage
            if let path = await path(of: image),
                let resizedImageData = resizedImage.tiffRepresentation
            {
                Self.cache.insert(resizedImageData, forKey: path)
                print("Resized and cached image thumbnail for \(path)")
            }
        } else {
            print("Failed to find a valid thumbnail!")
        }
    }

    private func resize(image: NSImage, resolution: CGFloat) async -> NSImage? {
        guard
            let tiffData = image.tiffRepresentation,
            let ciImage = CIImage(data: tiffData)
        else {
            return nil
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
            return nil
        }
        
        let resizedNSImage = NSImage(cgImage: cgImage, size: scaledSize)
        return resizedNSImage
    }
}
