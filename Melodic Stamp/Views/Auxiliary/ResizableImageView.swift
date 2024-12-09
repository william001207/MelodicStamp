//
//  ResizableImageView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import SwiftUI
import CryptoKit

struct ResizableImageView: View {
    static let gradation: CGFloat = 32
    
    var image: NSImage
    var maxResolution: CGFloat? = 128
    
    @State private var resizedImage: NSImage?
    
    var body: some View {
        Group {
            if let resizedImage {
                Image(nsImage: resizedImage)
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .task {
                        do {
                            try await readOrCache()
                        } catch {
                            print("Encountered error reading or caching an image: \(error)")
                        }
                    }
            }
        }
        .onChange(of: image) { _, _ in
            // reload image
            resizedImage = nil
        }
    }
    
    private var scaling: Int? {
        guard let maxResolution else { return nil }
        return Int(floor(maxResolution / Self.gradation))
    }
    
    private var resolution: CGFloat? {
        scaling.map { CGFloat($0) * Self.gradation }
    }
    
    private var path: String? {
        guard let scaling, let data = image.tiffRepresentation else { return nil }
        let digest = SHA256.hash(data: data)
        let hex = String(UInt(bitPattern: digest.hashValue), radix: 16)
        return "\(hex)@\(scaling)x"
    }
    
    private var hasData: Bool {
        path.map(CacheDirectory.imageCache.hasData(at:)) ?? false
    }
    
    private func readOrCache() async throws {
        guard !hasData else {
            // cached
            if let path, let data = try await CacheDirectory.imageCache.read(from: path) {
                print("Loading image cache \(path)...")
                resizedImage = NSImage(data: data)
                print("Loaded image cache \(path)")
            }
            return
        }
        
        guard let path, let resolution else { return }
        
        // resize and cache
        print("Resizing image \(path) to resolution \(resolution)...")
        let resizedImage = await resize(image: image, resolution: resolution)
        if let data = resizedImage?.tiffRepresentation {
            print("Caching image \(path)...")
            try await CacheDirectory.imageCache.write(data, to: path)
            print("Cached image \(path)")
        }
        self.resizedImage = resizedImage
    }
    
    private func resize(
        image: NSImage,
        resolution: CGFloat
    ) async -> NSImage? {
        let size = image.size
        let scale = min(
            resolution / size.width, resolution / size.height, 1
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
