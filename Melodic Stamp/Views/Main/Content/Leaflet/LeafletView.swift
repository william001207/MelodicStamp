//
//  LeafletView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/13.
//

import DominantColors
import SwiftUI
import SwiftState

struct LeafletView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(MetadataEditorModel.self) private var metadataEditor
    @Environment(LyricsModel.self) private var lyrics

    @SwiftUI.State private var dominantColors: [Color] = [.init(hex: 0x929292), .init(hex: 0xFFFFFF), .init(hex: 0x929292)]
    @SwiftUI.State private var isPlaying: Bool = false
    @SwiftUI.State private var isShowingLyrics: Bool = true
    
    @SwiftUI.State private var interactionStateDelegationProgress: CGFloat = .zero
    @SwiftUI.State private var interactionStateDispatch: DispatchWorkItem?
    @SwiftUI.State private var hasInteractionStateProgressRing: Bool = true
    
    lazy var interactionStateMachine: AppleMusicScrollViewInteractionState.Machine = .init(state: .following) { machine in
        machine.addRoutes(event: .userInteraction, transitions: [
            .following => .intermediate,
            .countingDown => .intermediate
        ])
        machine.addRoutes(event: .isolate, transitions: [
            .any => .isolated
        ])
        machine.addRoutes(event: .follow, transitions: [
            .any => .following
        ])
        machine.addRoutes(event: .countDown, transitions: [
            .intermediate => .countingDown
        ])
        
        machine.addHandler(event: .userInteraction) { context in
            interactionStateDispatch?.cancel()
            let dispatch = DispatchWorkItem {
                machine <-! .countDown
            }
            interactionStateDispatch = dispatch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: dispatch)
        }
        
        machine.addHandler(event: .countDown) { context in
            interactionStateDispatch?.cancel()
            let dispatch = DispatchWorkItem {
                machine <-! .follow
            }
            interactionStateDispatch = dispatch
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: dispatch)
            
            interactionStateDelegationProgress = 0
            withAnimation(.smooth(duration: 3)) {
                interactionStateDelegationProgress = 1
            }
        }
        
        machine.addHandler(.any => .countingDown) { context in
            hasInteractionStateProgressRing = true
        }
        
        machine.addHandler(.countingDown => .any) { context in
            hasInteractionStateProgressRing = false
        }
    }

    var body: some View {
        if !player.hasCurrentTrack {
            ExcerptView(tab: SidebarContentTab.leaflet)
        } else {
            ZStack {
                HStack(spacing: 50) {
                    @Bindable var player = player

                    let images: [NSImage] = if
                        let attachedPictures = player.current?.metadata[extracting: \.attachedPictures]?.current,
                        let cover = ThumbnailMaker.getCover(from: attachedPictures)?.image {
                        [cover]
                    } else { [] }

                    AliveButton(isOn: hasLyrics ? $isShowingLyrics : $player.isPlaying) {
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
                        DisplayLyricsView(interactionStateMachine: interactionStateMachine)
                            .overlay(alignment: .trailing) {
                                Group {
                                    if !interactionStateMachine.state.isDelegated {
                                        DisplayLyricsInteractionStateButton(
                                            interactionStateMachine: interactionStateMachine,
                                            progress: interactionStateDelegationProgress,
                                            hasProgressRing: hasInteractionStateProgressRing && interactionStateDelegationProgress > 0
                                        )
                                        .tint(.white)
                                    }
                                }
                                .transition(.blurReplace)
                                .animation(.bouncy, value: interactionStateMachine.state.isDelegated)
                                .padding(12)
                                .alignmentGuide(.trailing) { d in
                                    d[.leading]
                                }
                            }
                            .transition(.blurReplace)
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
            .animation(.bouncy, value: isShowingLyrics)
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
    @Previewable @SwiftUI.State var lyrics: LyricsModel = .init()

    LeafletView()
        .environment(lyrics)
}
