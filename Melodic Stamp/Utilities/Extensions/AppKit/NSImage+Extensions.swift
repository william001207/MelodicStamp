//
//  NSImage+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import AppKit
import CSFBAudioEngine

extension AttachedPicture {
    var image: NSImage? {
        .init(data: imageData)
    }
}

extension NSImage {
    var attachedPicture: AttachedPicture? {
        tiffRepresentation.flatMap { .init(imageData: $0) }
    }
}
