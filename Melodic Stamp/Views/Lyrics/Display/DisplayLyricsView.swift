//
//  DisplayLyricsView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Luminare
import SwiftUI

struct DisplayLyricsView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(LyricsModel.self) private var lyrics

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.lyricsAttachments) private var attachments

    @Binding var interactionState: AppleMusicLyricsViewInteractionState
    var onScrolling: ((ScrollPosition, CGPoint) -> ())?

    @State private var isHovering: Bool = false
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        // Avoids multiple instantializations
        let lines = lyrics.lines
        let highlightedRange = highlightedRange

        Group {
            if !lines.isEmpty {
                AppleMusicLyricsView(
                    interactionState: interactionState,
                    bounceDelay: 0.085,
                    range: 0 ..< lines.count,
                    highlightedRange: highlightedRange,
                    alignment: .center
                ) { index, _ in
                    DisplayLyricLineView(
                        line: lines[index], index: index,
                        highlightedRange: highlightedRange,
                        elapsedTime: elapsedTime,
                        shouldFade: !isHovering,
                        shouldAnimate: interactionState.isDelegated
                    )
                    .padding(.bottom, 21)
                } indicator: { index, _ in
                    let span = lyrics.storage?.parser.duration(before: index)
                    let beginTime = span?.begin
                    let endTime = span?.end

                    if let beginTime, let endTime {
                        let duration = endTime - beginTime
                        let progress = (elapsedTime - beginTime) / duration

                        return if duration >= 4, progress <= 1 {
                            .visible {
                                ProgressDotsContainerView(elapsedTime: elapsedTime, beginTime: beginTime, endTime: endTime)
                                    .padding(8.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 21)
                            }
                        } else { .invisible }
                    } else { return .invisible }
                } onScrolling: { position, point in
                    onScrolling?(position, point)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.clear
            }
        }
        .onHover { hover in
            withAnimation(.smooth(duration: 0.45)) {
                isHovering = hover
            }
        }
        .animation(.linear, value: elapsedTime) // For time interpolation
        .animation(.smooth, value: attachments)
    }

    private var elapsedTime: CGFloat {
        player.unwrappedPlaybackTime.elapsed
    }

    private var highlightedRange: Range<Int> {
        lyrics.highlight(at: elapsedTime)
    }
}
