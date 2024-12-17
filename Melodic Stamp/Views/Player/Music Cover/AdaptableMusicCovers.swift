//
//  AdaptableMusicCovers.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI

struct AdaptableMusicCovers<Content>: View where Content: View {
    typealias Entries = MetadataBatchEditingEntries<Set<AttachedPicture>>
    
    enum Layout {
        case flow
        case list
    }

    @Bindable var attachedPicturesHandler: AttachedPicturesHandlerModel

    var layout: Layout = .flow
    var contentWidth: CGFloat = 300, contentHeight: CGFloat = 200
    var entries: Entries
    @ViewBuilder var emptyView: () -> Content

    @State private var contentSize: CGSize = .zero

    var body: some View {
        Group {
            if types.isEmpty {
                emptyView()
            } else {
                switch layout {
                case .flow:
                    flowView()
                case .list:
                    listView()
                }
            }
        }
        .transition(.blurReplace)
        .animation(.bouncy, value: types)
    }

    private var types: Set<AttachedPicture.`Type`> {
        attachedPicturesHandler.types(of: entries)
    }

    @ViewBuilder private func flowView() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(Array(types).sorted(by: <), id: \.self) { type in
                    AdaptableMusicCoverControl(
                        attachedPicturesHandler: attachedPicturesHandler,
                        entries: entries,
                        type: type,
                        maxResolution: contentHeight
                    )
                    .containerRelativeFrame(
                        .horizontal, alignment: .center
                    ) { length, axis in
                        switch axis {
                        case .horizontal:
                            let count = max(1, types.count)
                            let proportional =
                                length / floor((length + contentWidth) / contentWidth)
                            return max(proportional, length / CGFloat(count))
                        case .vertical:
                            return length
                        }
                    }
                }
                .frame(height: contentHeight)
                .padding(.vertical, 8)
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
            types.count <= 1 || contentSize.width >= contentWidth * CGFloat(types.count)
        )
    }

    @ViewBuilder private func listView() -> some View {}
}
