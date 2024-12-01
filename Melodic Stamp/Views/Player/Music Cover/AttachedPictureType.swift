//
//  AttachedPictureType.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import SwiftUI
import CSFBAudioEngine

struct AttachedPictureType: View {
    var type: AttachedPicture.`Type`
    
    var body: some View {
        switch type {
        case .other:
            Text("Other")
        case .fileIcon:
            Text("File Icon")
        case .otherFileIcon:
            Text("Other File Icon")
        case .frontCover:
            Text("Front Cover")
        case .backCover:
            Text("Back Cover")
        case .leafletPage:
            Text("Leaflet Page")
        case .media:
            Text("Media")
        case .leadArtist:
            Text("Lead Artist")
        case .artist:
            Text("Artist")
        case .conductor:
            Text("Conductor")
        case .band:
            Text("Band")
        case .composer:
            Text("Composer")
        case .lyricist:
            Text("Lyricist")
        case .recordingLocation:
            Text("Recording Location")
        case .duringRecording:
            Text("During Recording")
        case .duringPerformance:
            Text("During Performance")
        case .movieScreenCapture:
            Text("Movie Screen Capture")
        case .colouredFish:
            Text("Coloured Fish")
        case .illustration:
            Text("Illustration")
        case .bandLogo:
            Text("Band Logo")
        case .publisherLogo:
            Text("Publisher Logo")
        @unknown default:
            EmptyView()
        }
    }
}
