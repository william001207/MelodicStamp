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

    @State private var dominantColors: [Color] = [.init(hex: 0x929292), .init(hex: 0xFFFFFF), .init(hex: 0x929292)]
    @State private var scrollability: BouncyScrollViewScrollability = .scrollsToHighlighted
    @State private var isPlaying: Bool = false
    @State private var isShowingLyrics: Bool = true

    @State private var scrollabilityDelegationProgress: CGFloat = .zero
    @State private var scrollabilityDispatch: DispatchWorkItem?
    @State private var hasScrollabilityProgressRing: Bool = true

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            ZStack {
                HStack(spacing: 50) {
                    let images: [NSImage] = if
                        let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image {
                        [cover]
                    } else { [] }

                    AliveButton {
                        withAnimation {
                            if hasLyrics {
                                isShowingLyrics.toggle()
                            } else {
                                player.isPlaying.toggle()
                            }
                        }
                    } label: {
                        MusicCover(
                            images: images, hasPlaceholder: true,
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
                    .onChange(of: player.currentIndex, initial: true) { _, _ in
                        if let cover = images.first {
                            Task { @MainActor in
                                dominantColors = try await extractDominantColors(from: cover)
                            }
                        }
                    }

                    if hasLyrics, isShowingLyrics {
                        DisplayLyricsView(scrollability: $scrollability)
                            .overlay(alignment: .trailing) {
                                Group {
                                    if !scrollability.isDelegated {
                                        DisplayLyricsScrollabilityButton(
                                            scrollability: $scrollability,
                                            progress: scrollabilityDelegationProgress,
                                            hasProgressRing: hasScrollabilityProgressRing && scrollabilityDelegationProgress > 0
                                        )
                                        .tint(.white)
                                    }
                                }
                                .transition(.blurReplace)
                                .animation(.bouncy, value: scrollability.isDelegated)
                                .alignmentGuide(.trailing) { d in
                                    d[.leading]
                                }
                            }
                            .transition(.blurReplace)
                            .onChange(of: scrollability) { _, _ in
                                switch scrollability {
                                case .scrollsToHighlighted:
                                    hasScrollabilityProgressRing = false
                                case .waitsForScroll:
                                    hasScrollabilityProgressRing = false
                                case .definedByApplication:
                                    hasScrollabilityProgressRing = true

                                    scrollabilityDelegationProgress = .zero
                                    withAnimation(.smooth(duration: 3)) {
                                        scrollabilityDelegationProgress = 1
                                    }

                                    let dispatch = DispatchWorkItem {
                                        scrollability = .scrollsToHighlighted
                                    }
                                    scrollabilityDispatch = dispatch
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: dispatch)
                                case .definedByUser:
                                    hasScrollabilityProgressRing = false

                                    scrollabilityDispatch?.cancel()
                                    withAnimation(.smooth) {
                                        scrollabilityDelegationProgress = 1
                                    }
                                }
                            }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.bouncy, value: hasLyrics)
            .background {
                AnimatedGrid(colors: dominantColors)
                    .brightness(-0.075)
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
                guard let newValue else { return }
                lyrics.clear(newValue.url)

                Task {
                    let raw = await newValue.metadata.poll(for: \.lyrics).current
                    await lyrics.read(raw)
                }
            }
            .onChange(of: isShowingLyrics) { _, newValue in
                guard newValue else { return }
                guard let current = player.current else { return }
                lyrics.clear(current.url)

                Task {
                    let raw = await current.metadata.poll(for: \.lyrics).current
                    await lyrics.read(raw)
                }
            }
            
            .onReceive(player.isPlayingPublisher) { isPlaying in
                self.isPlaying = isPlaying
            }
            .environment(\.colorScheme, .dark)
        }
    }

    private var hasLyrics: Bool {
        !lyrics.lines.isEmpty
    }

    private func extractDominantColors(from image: NSImage) async throws -> [Color] {
        let colors = try DominantColors.dominantColors(
            nsImage: image, quality: .fair,
            algorithm: .CIEDE2000, maxCount: 3, sorting: .lightness
        )
        return colors.map(Color.init)
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    @Previewable @State var lyrics: LyricsModel = .init()

    LeafletView()
        .environment(lyrics)
}
