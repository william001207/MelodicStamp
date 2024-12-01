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
    var state: MetadataValueState<Set<AttachedPicture>>

    @State private var contentSize: CGSize = .zero

    var body: some View {
        switch layout {
        case .flow:
            flowView()
        case .grid:
            gridView()
        }
    }
    
    private var types: Set<AttachedPicture.`Type`> {
        switch state {
        case .undefined:
            []
        case .fine(let value):
            Set(value.current.map(\.type))
        case .varied(let values):
            Set(values.current.values.flatMap(\.self).map(\.type))
        }
    }

    private var count: Int {
        types.count
    }

    @ViewBuilder private func cover(type: AttachedPicture.`Type`) -> some View {
        let attachedPictures: [AttachedPicture] = switch state {
        case .undefined:
            []
        case .fine(let value):
                .init(value.current)
        case .varied(let values):
            values.current.values.flatMap(\.self)
        }
        
        let images = attachedPictures.compactMap(\.image)
        
        VStack(spacing: 8) {
            attachedPictureType(type)
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
            
            MusicCover(
                images: images,
                maxResolution: 64 * max(1, round(contentSize.width / 64))
            )
            .padding(.horizontal, 16)
            .containerRelativeFrame(
                .horizontal, alignment: .center
            ) { length, axis in
                switch axis {
                case .horizontal:
                    let count = max(1, count)
                    let proportional =
                    length / floor((length + maxWidth) / maxWidth)
                    return max(proportional, length / CGFloat(count))
                case .vertical:
                    return length
                }
            }
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder private func flowView() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(Array(types), id: \.self) { type in
                    cover(type: type)
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
        .scrollDisabled(
           count <= 1 || contentSize.width >= maxWidth * CGFloat(count)
        )
    }

    @ViewBuilder private func gridView() -> some View {

    }

    @ViewBuilder private func attachedPictureType(
        _ type: AttachedPicture.`Type`
    ) -> some View {
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
