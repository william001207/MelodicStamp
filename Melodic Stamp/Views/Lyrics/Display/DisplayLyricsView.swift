//
//  DisplayLyricsView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import Defaults
import Luminare
import SwiftUI

struct DisplayLyricsView: View {
    struct Identifier: Hashable {
        var storageHashValue: Int?
        var typeSizeHashValue: Int?
        var attachmentsHashValue: Int?

        func hash(into hasher: inout Hasher) {
            hasher.combine(storageHashValue)
            hasher.combine(typeSizeHashValue)
            hasher.combine(attachmentsHashValue)
        }
    }

    @Environment(PlaylistModel.self) private var playlist
    @Environment(PlayerModel.self) private var player
    @Environment(LyricsModel.self) private var lyrics

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Default(.lyricsAttachments) private var attachments

    @Binding var interactionState: AppleMusicLyricsViewInteractionState
    var onScrolling: ((ScrollPosition, CGPoint) -> ())?

    @State private var isHovering: Bool = false
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        // Avoids multiple instantializations
        let lines = lyrics.lines
        let highlightedRange = lyrics.highlight(at: elapsedTime, in: playlist.currentTrack?.url)

        Group {
            if !lines.isEmpty {
                AppleMusicLyricsView(
                    interactionState: interactionState,
                    range: 0 ..< lines.count,
                    highlightedRange: highlightedRange,
                    alignment: .center,
                    identifier: identifier // To make the changes synchronized within the scope of lyrics
                ) { index, _ in
                    DisplayLyricLineView(
                        line: lines[index], index: index,
                        highlightedRange: highlightedRange,
                        elapsedTime: elapsedTime,
                        shouldFade: !isHovering,
                        shouldAnimate: interactionState.isDelegated
                    )
                } indicator: { index, _ in
                    let span = lyrics.storage?.parser.duration(before: index)
                    let beginTime = span?.begin
                    let endTime = span?.end

                    if let beginTime, let endTime {
                        let duration = endTime - beginTime
                        let progress = (elapsedTime - beginTime) / duration

                        return if duration >= 4.5, progress <= 1 {
                            .visible {
                                ProgressDotsContainerView(elapsedTime: elapsedTime, beginTime: beginTime, endTime: endTime)
                                    .padding(8.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 21)
                            }
                        } else { .invisible }
                    } else { return .invisible }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.clear
            }
        }
        .animation(.smooth(duration: 0.45), value: isHovering)
        .animation(.linear(duration: PlayerModel.interval), value: elapsedTime) // For time interpolation
        .onHover { hover in
            isHovering = hover
        }
    }

    private var identifier: Identifier {
        .init(
            storageHashValue: lyrics.storage?.hashValue,
            typeSizeHashValue: dynamicTypeSize.hashValue,
            attachmentsHashValue: attachments.hashValue
        )
    }

    private var elapsedTime: CGFloat {
        player.unwrappedPlaybackTime.elapsed
    }

    private var highlightedRange: Range<Int> {
        lyrics.highlight(at: elapsedTime)
    }
}
