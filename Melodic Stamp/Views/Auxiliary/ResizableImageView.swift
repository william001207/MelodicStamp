//
//  ResizableImageView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import SmartCache

struct ResizableImageView: View {
    static let gradation: CGFloat = 32
    static var cache: SmartCache<URL, Data> = .init(
        maximumCachedValues: 256,
        cacheDirectory: .cachesDirectory.appending(path: "ImageCache", directoryHint: .isDirectory)
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
                Color.clear
                    .task(priority: .background) {
                        await getOrGenerateThumbnail()
                    }
            }
        }
        .onChange(of: image) { oldImage, newImage in
            Task {
                let oldPath = await path(of: oldImage), newPath = await path(of: newImage)
                guard newPath != oldPath else { return }
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
    
    private func isCached() async throws -> Bool {
        await !(try path(of: image).flatMap(Self.cache.value(forKey:))?.isEmpty ?? true)
    }
    
    private func path(of image: NSImage) async -> URL? {
        return await withCheckedContinuation { continuation in
            guard let scaling, let data = image.tiffRepresentation else { return continuation.resume(returning: nil) }
            let hex = String(UInt(bitPattern: data.hashValue), radix: 16)
            continuation.resume(returning: URL(string: "\(hex)@\(scaling)x"))
        }
    }

    private func getOrGenerateThumbnail() async throws {
        guard let resolution else { return }

        if let path = await path(of: image) {
            // load from cache
        }
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
