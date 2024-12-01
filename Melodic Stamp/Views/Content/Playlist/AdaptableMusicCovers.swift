//
//  AdaptableMusicCovers.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI

struct AdaptableMusicCovers: View {
    enum Layout {
        case flow
        case grid
    }

    var layout: Layout = .flow
    var maxWidth: CGFloat = 300
    var value: MetadataValueState<Set<AttachedPicture>>
    
    @State private var contentSize: CGSize = .zero

    var body: some View {
        switch value {
        case .undefined:
            Color.red
        case .fine(let values):
            if values.current.isEmpty {
                MusicCover()
            } else {
                switch layout {
                case .flow:
                    flowView(values: values)
                case .grid:
                    gridView(values: values)
                }
            }
        case .varied(let valueSetter):
            Color.blue
        }
    }

    @ViewBuilder private func flowView(values: EditableMetadata.Values<Set<AttachedPicture>>) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(Array(values.current), id: \.type) {
                    attachedPicture in
                    if let image = attachedPicture.image {
                        VStack(spacing: 8) {
                            attachedPictureType(attachedPicture.type)
                                .font(.caption)
                                .foregroundStyle(.placeholder)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background {
                                    Rectangle()
                                        .fill(.regularMaterial)
                                        .background(.placeholder)
                                }
                                .clipShape(.capsule)
                            
                            MusicCover(image: image, maxResolution: 64 * max(1, round(contentSize.width / 64)))
                                .padding(.horizontal, 16)
                                .containerRelativeFrame(
                                    .horizontal, alignment: .center
                                ) { length, axis in
                                    switch axis {
                                    case .horizontal:
                                        let count = max(1, values.current.count)
                                        let proportional = length / floor((length + maxWidth) / maxWidth)
                                        return max(proportional, length / CGFloat(count))
                                    case .vertical:
                                        return length
                                    }
                                }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .scrollTargetLayout()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                contentSize = size
            }
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollDisabled(values.current.count <= 1 || contentSize.width >= maxWidth * CGFloat(values.current.count))
    }

    @ViewBuilder private func gridView(values: EditableMetadata.Values<Set<AttachedPicture>>) -> some View {

    }
    
    @ViewBuilder private func attachedPictureType(_ type: AttachedPicture.`Type`) -> some View {
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
