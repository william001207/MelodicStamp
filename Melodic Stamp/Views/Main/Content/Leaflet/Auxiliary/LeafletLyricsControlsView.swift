//
//  LeafletLyricsControlsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import SwiftUI

struct LeafletLyricsControlsView: View {
    @Environment(\.lyricsTypeSizes) private var availableTypeSizes

    @Binding var typeSize: DynamicTypeSize

    @State private var isHovering: Bool = false

    var body: some View {
        Group {
            if abs(availableTypeSizes.lowerBound.distance(to: availableTypeSizes.upperBound)) > 1 {
                VStack(spacing: 12) {
                    // Sadly we can't add toggles for lyrics attachments here, as it will trigger implicit view resizing and cause the whole lyrics to misalign
                    // See commits before c4e3d8b067a7bc72868d1f8ff2e3e9742bd4c138
                    VStack(spacing: 4) {
                        AliveButton {
                            typeSize -~ availableTypeSizes.lowerBound
                        } label: {
                            Image(systemSymbol: .textformatSizeSmaller)
                                .foregroundStyle(
                                    isHovering && typeSize > availableTypeSizes.lowerBound ? .primary : .quaternary
                                )
                                .frame(height: 24)
                        }

                        ForEach(availableTypeSizes, id: \.hashValue) { size in
                            let isSelected = typeSize == size
                            AliveButton {
                                typeSize = size
                            } label: {
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .scaleEffect(isSelected ? 1.5 : 1)
                                    .foregroundStyle(
                                        isSelected ? .primary
                                            : isHovering ? .tertiary : .quaternary
                                    )
                                    .padding(4)
                            }
                        }

                        AliveButton {
                            typeSize +~ availableTypeSizes.upperBound
                        } label: {
                            Image(systemSymbol: .textformatSizeLarger)
                                .foregroundStyle(
                                    isHovering && typeSize < availableTypeSizes.upperBound ? .primary : .quaternary
                                )
                                .frame(height: 24)
                        }
                    }
                }
            }
        }
        .font(.title2)
        .padding(.vertical, 12)
        .frame(width: 48)
        .hoverableBackground()
        .clipShape(.capsule)
        .onHover { hover in
            isHovering = hover
        }
        .animation(.smooth(duration: 0.25), value: isHovering)
    }
}
