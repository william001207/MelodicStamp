//
//  TrackView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import CSFBAudioEngine
import Luminare
import SwiftUI

struct TrackView: View {
    @Environment(PlayerModel.self) private var player

    var track: Track
    var isSelected: Bool

    @State private var isHovering: Bool = false
    @State private var isAboutToDoubleClick: Bool = false
    @State private var cancelDoubleClickDispatch: DispatchWorkItem?

    var body: some View {
        HStack(alignment: .center) {
            let metadataState = track.metadata.state
            let isMetadataModified = track.metadata.isModified

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    switch metadataState {
                    case .loading:
                        Text("Loading…")
                            .foregroundStyle(.placeholder)
                    case .fine, .saving, .interrupted:
                        titleView()
                    default:
                        EmptyView()
                    }

                    switch metadataState {
                    case let .interrupted(error), let .dropped(error):
                        Image(systemSymbol: .exclamationmarkCircleFill)
                            .foregroundStyle(.red)
                            .luminarePopover {
                                errorView(error: error)
                                    .padding()
                            }
                    default:
                        EmptyView()
                    }

                    Spacer()
                }
                .frame(height: 24)
                .font(.title3)

                HStack(alignment: .center, spacing: 4) {
                    if isMetadataModified {
                        Circle()
                            .foregroundStyle(.tint)
                            .tint(isSelected ? .primary : .accent)
                            .padding(2)
                            .animation(nil, value: isSelected)
                    }

                    if let duration = track.metadata.properties.duration.flatMap(Duration.init) {
                        DurationText(duration: duration)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                    }

                    Text(track.url.lastPathComponent)
                        .foregroundStyle(.placeholder)

                    Spacer()
                }
                .frame(height: 12)
                .font(.caption)
            }
            .transition(.blurReplace)
            .opacity(opacity)
            .animation(.default.speed(2), value: metadataState)
            .animation(.default.speed(2), value: isMetadataModified)
            .animation(.default.speed(2), value: isCurrentTrack)
            .animation(.default.speed(2), value: player.isPlayable)
            .animation(.default.speed(2), value: player.isPlaying)

            AliveButton {
                player.play(track: track)
            } label: {
                coverView()
            }
        }
        .padding(6)
        .padding(.trailing, -1)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
        .onAppear {
            EventMonitorManager.shared.addLocalMonitor(
                for: track,
                matching: [.leftMouseDown]
            ) { event in
                guard isHovering else { return event }

                if isAboutToDoubleClick {
                    // Double click!
                    cancelDoubleClickDispatch?.cancel()
                    isAboutToDoubleClick = false
                    player.play(track: track)
                } else {
                    let dispatch = DispatchWorkItem {
                        isAboutToDoubleClick = false
                    }
                    isAboutToDoubleClick = true
                    cancelDoubleClickDispatch = dispatch
                    DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval, execute: dispatch)
                }

                return event
            }
        }
        .onDisappear {
            EventMonitorManager.shared.removeMonitor(for: track)
        }
        .onReceive(track.metadata.applyPublisher) { _ in
            guard isCurrentTrack else { return }
            track.metadata.updateNowPlayingInfo()
        }
    }

    private var opacity: CGFloat {
        if isSelected {
            1
        } else if player.isPlayable {
            if isCurrentTrack {
                1
            } else {
                if player.isPlaying {
                    0.45
                } else {
                    0.65
                }
            }
        } else {
            1
        }
    }

    private var isCurrentTrack: Bool {
        player.track == track
    }

    @ViewBuilder private func titleView() -> some View {
        if isCurrentTrack {
            MarqueeScrollView(animate: false) {
                MusicTitle(track: track)
            }
        } else {
            MusicTitle(track: track)
        }
    }

    @ViewBuilder private func coverView() -> some View {
        let isInitialized = track.metadata.state.isInitialized

        ZStack {
            if isInitialized, let thumbnail = track.metadata.thumbnail {
                MusicCover(
                    images: [thumbnail], hasPlaceholder: false, cornerRadius: 4
                )
                .overlay {
                    if isHovering {
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(0.25)
                            .blendMode(.darken)
                    }
                }

                if isHovering, isInitialized {
                    Image(systemSymbol: .playFill)
                        .foregroundStyle(.white)
                }
            } else {
                if isHovering, isInitialized {
                    Image(systemSymbol: .playFill)
                        .foregroundStyle(.primary)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 4))
        .frame(width: 50, height: 50)
        .font(.title3)
        .contentTransition(.symbolEffect(.replace))
    }

    @ViewBuilder private func errorView(error: MetadataError) -> some View {
        Group {
            switch error {
            case .invalidFormat:
                Text("Invalid format.")
            case .fileNotFound:
                Text("File not found.")
            case .readingPermissionNotGranted:
                Text("Reading permission not granted.")
            case .writingPermissionNotGranted:
                Text("Writing permission not granted.")
            }
        }
        .foregroundStyle(.red)
    }
}
