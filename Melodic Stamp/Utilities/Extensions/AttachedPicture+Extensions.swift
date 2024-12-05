//
//  AttachedPicture+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import AppKit
import CSFBAudioEngine

extension AttachedPicture {
    var image: NSImage? {
        .init(data: imageData)
    }

    var category: AttachedPictureCategory {
        type.category
    }

    // hack
    static var allTypes: [AttachedPicture.`Type`] {
        [
            .other,
            .fileIcon,
            .otherFileIcon,
            .frontCover,
            .backCover,
            .leafletPage,
            .media,
            .leadArtist,
            .artist,
            .conductor,
            .band,
            .composer,
            .lyricist,
            .recordingLocation,
            .duringRecording,
            .duringPerformance,
            .movieScreenCapture,
            .colouredFish,
            .illustration,
            .bandLogo,
            .publisherLogo,
        ]
    }
}

enum AttachedPictureCategory: String, Hashable, Identifiable, Equatable, CaseIterable {
    case media
    case band
    case staff
    case scenes
    case metadata

    var id: String {
        rawValue
    }

    var allTypes: [AttachedPicture.`Type`] {
        AttachedPicture.allTypes.filter { $0.category == self }
    }

    var order: Int {
        switch self {
        case .media: 0
        case .band: 1
        case .staff: 2
        case .scenes: 3
        case .metadata: 4
        }
    }
}

extension AttachedPictureCategory: Comparable {
    public static func < (lhs: AttachedPictureCategory, rhs: AttachedPictureCategory) -> Bool {
        lhs.order < rhs.order
    }
}

extension AttachedPicture.`Type` {
    var order: Int {
        switch self {
        case .frontCover: 0x0
        case .backCover: 0x1
        case .illustration: 0x2
        case .leafletPage: 0x3
        case .media: 0x4
        case .bandLogo: 0x10
        case .publisherLogo: 0x11
        case .band: 0x12
        case .leadArtist: 0x20
        case .artist: 0x21
        case .composer: 0x22
        case .conductor: 0x23
        case .lyricist: 0x24
        case .duringPerformance: 0x30
        case .duringRecording: 0x31
        case .recordingLocation: 0x32
        case .movieScreenCapture: 0x33
        case .fileIcon: 0x40
        case .otherFileIcon: 0x41
        case .colouredFish: 0x42
        case .other: 0x43
        @unknown default: .max
        }
    }

    var category: AttachedPictureCategory {
        switch self {
        case .frontCover, .backCover, .illustration, .leafletPage, .media: .media
        case .bandLogo, .publisherLogo, .band: .band
        case .leadArtist, .artist, .composer, .conductor, .lyricist: .staff
        case .duringPerformance, .duringRecording, .recordingLocation, .movieScreenCapture: .scenes
        case .fileIcon, .otherFileIcon, .colouredFish, .other: .metadata
        @unknown default: .metadata
        }
    }
}

extension AttachedPicture.`Type`: @retroactive Comparable {
    public static func < (lhs: AttachedPicture.`Type`, rhs: AttachedPicture.`Type`) -> Bool {
        lhs.order < rhs.order
    }
}
