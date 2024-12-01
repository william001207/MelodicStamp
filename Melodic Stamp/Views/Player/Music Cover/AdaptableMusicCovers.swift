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

    @ViewBuilder private func flowView() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(Array(types), id: \.self) { type in
                    AdaptableMusicCoverControl(
                        state: state,
                        type: type,
                        maxResolution: max(1, round(contentSize.width / 64) * 64)
                    )
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
}
