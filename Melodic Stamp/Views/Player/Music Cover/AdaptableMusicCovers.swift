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

    @Bindable var attachedPicturesHandler: AttachedPicturesHandlerModel

    var layout: Layout = .flow
    var contentWidth: CGFloat = 300, contentHeight: CGFloat = 200
    var state: MetadataValueState<Set<AttachedPicture>>

    @State private var contentSize: CGSize = .zero

    var body: some View {
        Group {
            if types.isEmpty {
                emptyView()
            } else {
                switch layout {
                case .flow:
                    flowView()
                case .grid:
                    gridView()
                }
            }
        }
        .transition(.blurReplace)
        .animation(.bouncy, value: types)
    }

    private var types: Set<AttachedPicture.`Type`> {
        attachedPicturesHandler.types(state: state)
    }

    @ViewBuilder private func emptyView() -> some View {}

    @ViewBuilder private func flowView() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(Array(types).sorted(by: <), id: \.self) { type in
                    AdaptableMusicCoverControl(
                        attachedPicturesHandler: attachedPicturesHandler,
                        state: state,
                        type: type,
                        maxResolution: max(1, round(contentSize.width / 64) * 64)
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
                .padding(.bottom, 8)
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

    @ViewBuilder private func gridView() -> some View {}
}
