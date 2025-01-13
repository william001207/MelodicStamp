//
//  LeafletLyricsControlsView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/10.
//

import SwiftUI

struct LeafletLyricsControlsView: View {
    @Environment(\.lyricsAttachments) private var availableAttachments
    @Environment(\.lyricsTypeSizes) private var availableTypeSizes

    @Binding var attachments: LyricsAttachments
    @Binding var typeSize: DynamicTypeSize

    @State private var isHovering: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // MARK: Translation

            if availableAttachments.contains(.translation) {
                AliveButton {
                    attachments.toggle(.translation)
                } label: {
                    Image(systemSymbol: .translate)
                        .foregroundStyle(
                            attachments.contains(.translation) ? .primary
                                : isHovering ? .tertiary : .quaternary
                        )
                        .frame(height: 24)
                }
            }

            // MARK: Roman

            if availableAttachments.contains(.roman) {
                AliveButton {
                    attachments.toggle(.roman)
                } label: {
                    Image(systemSymbol: .characterPhonetic)
                        .foregroundStyle(
                            attachments.contains(.roman) ? .primary
                                : isHovering ? .tertiary : .quaternary
                        )
                        .frame(height: 24)
                }
            }

            // MARK: Type Sizes

            if abs(availableTypeSizes.lowerBound.distance(to: availableTypeSizes.upperBound)) > 1 {
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
