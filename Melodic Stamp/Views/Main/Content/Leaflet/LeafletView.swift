//
//  LeafletView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/13.
//

import DominantColors
import SwiftUI

struct LeafletView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor
    @Environment(LyricsModel.self) private var lyrics

    @State private var interaction: AppleMusicLyricsViewInteractionModel = .init()

    @State private var isPlaying: Bool = false
    @State private var isShowingLyrics: Bool = true

    @State private var dominantColors: [Color] = [.init(hex: 0x929292), .init(hex: 0xFFFFFF), .init(hex: 0x929292)]

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            ZStack {
                if hasCover || hasLyrics {
                    HStack(spacing: 50) {
                        if let cover {
                            coverView(cover)
                                .onChange(of: player.currentIndex, initial: true) { _, _ in
                                    Task { @MainActor in
                                        dominantColors = try await extractDominantColors(from: cover)
                                    }
                                }
                        }

                        if hasLyrics, isShowingLyrics {
                            lyricsView()
                                .transition(.blurReplace(.downUp))
                        }
                    }
                    .containerRelativeFrame(.horizontal, alignment: .center) { length, axis in
                        switch axis {
                        case .horizontal:
                            let padding = length * 0.1
                            return length - 2 * min(100, padding)
                        case .vertical:
                            return length
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.bouncy, value: hasLyrics)
            .animation(.bouncy, value: isShowingLyrics)
            .background {
                if hasCover {
                    ZStack {
                        AnimatedGrid(colors: dominantColors)

                        Color.black
                            .opacity(0.35)
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)

                        LinearGradient(
                            colors: [.clear, .accent],
                            startPoint: .top, endPoint: .bottom
                        )
                        .opacity(0.65)
                        .brightness(-0.075)
                        .blendMode(.multiply)
                    }
                    .onAppear {
                        dominantColors = []
                    }
                }
            }

            // Read lyrics
            // Don't extract this logic or modify the tasks!
            .onAppear {
                guard let current = player.current else { return }

                Task {
                    let raw = await current.metadata.poll(for: \.lyrics).current
                    await lyrics.read(raw)
                }
            }
            .onChange(of: player.current) { _, newValue in
                lyrics.clear(newValue?.url)
                guard let newValue else { return }

                Task {
                    let raw = await newValue.metadata.poll(for: \.lyrics).current
                    await lyrics.read(raw)
                }
            }

            .onReceive(player.isPlayingPublisher) { isPlaying in
                self.isPlaying = isPlaying
            }
            .colorScheme(.dark)
        }
    }

    private var cover: NSImage? {
        if
            let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
            let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image {
            cover
        } else { nil }
    }

    private var hasCover: Bool { cover != nil }

    private var hasLyrics: Bool {
        !lyrics.lines.isEmpty
    }

    @ViewBuilder private func coverView(_ cover: NSImage) -> some View {
        @Bindable var player = player

        AliveButton(isOn: hasLyrics ? $isShowingLyrics : $player.isPlaying) {
            MusicCover(
                images: [cover], hasPlaceholder: true,
                cornerRadius: 12
            )
        }
        .containerRelativeFrame(.vertical, alignment: .center) { length, axis in
            switch axis {
            case .horizontal:
                length
            case .vertical:
                min(500, length * 0.5)
            }
        }
        .scaleEffect(isPlaying ? 1 : 0.85, anchor: .center)
        .shadow(radius: isPlaying ? 20 : 10)
        .animation(.spring(duration: 0.65, bounce: 0.45, blendDuration: 0.75), value: isPlaying)
    }

    @ViewBuilder private func lyricsView() -> some View {
        DisplayLyricsView(interactionState: $interaction.state) { position, _ in
            guard position.isPositionedByUser else { return }
            interaction.reset()
        }
        .overlay(alignment: .trailing) {
            Group {
                if !interaction.state.isDelegated {
                    AppleMusicLyricsViewInteractionStateButton(
                        interactionState: $interaction.state,
                        progress: interaction.delegationProgress,
                        hasProgressRing: interaction.hasProgressRing && interaction.delegationProgress > 0
                    )
                    .tint(.white)
                    .transition(.blurReplace(.downUp))
                }
            }
            .animation(.bouncy, value: interaction.state.isDelegated)
            .padding(12)
            .alignmentGuide(.trailing) { d in
                d[.leading]
            }
        }
    }

    private func extractDominantColors(from image: NSImage) async throws -> [Color] {
        let colors = try DominantColors.dominantColors(
            nsImage: image, quality: .fair,
            algorithm: .CIEDE2000, maxCount: 3, options: [.excludeWhite], sorting: .lightness
        )
        return colors.map(Color.init)
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    @Previewable @State var lyrics: LyricsModel = .init()

    LeafletView()
        .environment(lyrics)
}
