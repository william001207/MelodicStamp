//
//  MiniPlayer.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//


import SwiftUI
import SFSafeSymbols

struct MiniPlayer: View {
    enum ActiveControl: Equatable {
        case progress
        case volume
        
        var id: PlayerNamespace {
            switch self {
            case .progress: .progressBar
            case .volume: .volumeBar
            }
        }
    }
    
    var namespace: Namespace.ID
    
    @State var model: PlayerModel
    
    @State private var activeControl: ActiveControl = .progress
    
    @State private var isTitleHovering: Bool = false
    @State private var isProgressBarHovering: Bool = false
    @State private var isProgressBarActive: Bool = false
    @State private var isPressingSpace: Bool = false
    
    @State private var shouldUseRemainingDuration: Bool = true
    @State private var progressBarExternalOvershootSign: FloatingPointSign?
    
    @State private var previousSongButtonBounceAnimation: Bool = false
    @State private var nextSongButtonBounceAnimation: Bool = false
    @State private var speakerButtonBounceAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            header()
                .padding(.horizontal, 4)
                .onHover { hover in
                    withAnimation(.default.speed(2)) {
                        isTitleHovering = hover
                    }
                }
            
            HStack(alignment: .center, spacing: 12) {
                if !isProgressBarExpanded {
                    leadingControls()
                        .transition(.blurReplace)
                }
                
                progressBar()
                
                if activeControl == .volume {
                    Group {
                        if isProgressBarExpanded {
                            Spacer()
                                .frame(width: 0)
                        } else {
                            AliveButton {
                                activeControl = .progress
                            } label: {
                                Image(systemSymbol: .chevronLeft)
                            }
                        }
                    }
                    .transition(.blurReplace)
                }
                
                if activeControl == .volume || !isProgressBarExpanded {
                    trailingControls()
                        .transition(.blurReplace)
                }
            }
            .frame(height: 16)
            .animation(.default, value: isProgressBarHovering)
            .animation(.default, value: isProgressBarActive)
            .animation(.default, value: activeControl)
        }
        .padding(12)
        .background(Color.clear)
        
        .focusable()
        .focusEffectDisabled()
        
        .onKeyPress(keys: [.space], phases: .all) { key in
            guard model.hasCurrentTrack else { return .ignored }
            
            switch key.phase {
            case .down:
                guard !isPressingSpace else { return .ignored }
                
                model.togglePlayPause()
                isPressingSpace = true
                return .handled
            case .up:
                isPressingSpace = false
                return .handled
            default:
                return .ignored
            }
        }
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .all) { key in
            switch key.phase {
            case .down:
                guard model.hasCurrentTrack else { return .ignored }
                
                let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus
                let modifiers = key.modifiers
                
                if modifiers.contains(.command) {
                    switch sign {
                    case .plus:
                        model.nextTrack()
                        nextSongButtonBounceAnimation.toggle()
                    case .minus:
                        model.previousTrack()
                        previousSongButtonBounceAnimation.toggle()
                    }
                    
                    return .handled
                }
                
                let hasShift = modifiers.contains(.shift)
                let hasOption = modifiers.contains(.option)
                let multiplier: CGFloat = if hasShift && !hasOption {
                    5
                } else if hasOption && !hasShift {
                    0.1
                } else { 1 }
                
                let inRange = switch activeControl {
                case .progress:
                    model.adjustTime(multiplier: multiplier, sign: sign)
                case .volume:
                    model.adjustVolume(multiplier: multiplier, sign: sign)
                }
                
                if !inRange {
                    progressBarExternalOvershootSign = sign
                }
                
                return .handled
            case .up:
                progressBarExternalOvershootSign = nil
                return .ignored
            default:
                return .ignored
            }
        }
        .onKeyPress(.escape) {
            guard activeControl == .volume else { return .ignored }
            
            activeControl = .progress
            return .handled
        }
        .onKeyPress(keys: ["m"], phases: .down) { key in
            model.isMuted.toggle()
            return .handled
        }
    }
    
    private var isProgressBarExpanded: Bool {
        isProgressBarHovering || isProgressBarActive
    }
    
    @ViewBuilder private func header() -> some View {
        HStack(alignment: .center, spacing: 12) {
            Group {
                AliveButton(enabledStyle: .init(.secondary)) {
                } label: {
                    Image(systemSymbol: .squareAndArrowUp)
                }
            }
            .opacity(isTitleHovering ? 1 : 0)
            
            AliveButton(enabledStyle: .init(.secondary)) {
                let hasShift = NSEvent.modifierFlags.contains(.shift)
                model.playbackMode = switch model.playbackMode {
                case .single:
                    hasShift ? .shuffle : .sequential
                case .sequential:
                    hasShift ? .single : .loop
                case .loop:
                    hasShift ? .sequential : .shuffle
                case .shuffle:
                    hasShift ? .loop : .single
                }
            } label: {
                model.playbackMode.image
                    .frame(width: 16)
                    .contentTransition(.symbolEffect(.replace))
            }
            
            ShrinkableMarqueeScrollView {
                MusicTitle(model: model)
            }
            .contentTransition(.numericText())
            .animation(.default, value: model.currentIndex)
            .padding(.bottom, 2)
            
            Group {
                AliveButton(enabledStyle: .init(.secondary)) {
                } label: {
                    Image(systemSymbol: .arrowUpLeftAndArrowDownRight)
                }
                .matchedGeometryEffect(id: PlayerNamespace.expandShrinkButton, in: namespace)
            }
            .opacity(isTitleHovering ? 1 : 0)
        }
    }
    
    @ViewBuilder private func leadingControls() -> some View {
        Group {
            AliveButton {
                model.previousTrack()
                previousSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .backwardFill)
            }
            .disabled(!model.hasPreviousTrack)
            .symbolEffect(.bounce, value: previousSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.previousSongButton, in: namespace)
            
            AliveButton {
                model.togglePlayPause()
                isPressingSpace = false
            } label: {
                playPauseIcon(height: 16)
                    .frame(width: 16)
                    .contentTransition(.symbolEffect(.replace.upUp))
            }
            .scaleEffect(isPressingSpace ? 0.75 : 1, anchor: .center)
            .animation(.bouncy, value: isPressingSpace)
            .matchedGeometryEffect(id: PlayerNamespace.playPauseButton, in: namespace)
            
            AliveButton {
                model.nextTrack()
                nextSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .forwardFill)
            }
            .disabled(!model.hasNextTrack)
            .symbolEffect(.bounce, value: nextSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.nextSongButton, in: namespace)
        }
        .disabled(!model.hasCurrentTrack)
    }
    
    @ViewBuilder private func trailingControls() -> some View {
        AliveButton {
            switch activeControl {
            case .progress:
                activeControl = .volume
            case .volume:
                model.isMuted.toggle()
            }
        } label: {
            model.speakerImage
                .imageScale(.large)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 20)
        }
        .symbolEffect(.bounce, value: activeControl)
        .symbolEffect(.bounce, value: speakerButtonBounceAnimation)
        .matchedGeometryEffect(id: PlayerNamespace.volumeButton, in: namespace)
        
        AliveButton {
        } label: {
            Image(systemSymbol: .listTriangle)
                .imageScale(.large)
        }
        .matchedGeometryEffect(id: PlayerNamespace.playlistButton, in: namespace)
    }
    
    @ViewBuilder private func progressBar() -> some View {
        HStack(alignment: .center, spacing: 8) {
            Group {
                if activeControl == .progress {
                    let time = if shouldUseRemainingDuration {
                        model.timeRemaining
                    } else {
                        model.timeElapsed
                    }
                    
                    DurationText(
                        duration: .seconds(time),
                        sign: shouldUseRemainingDuration ? .minus : .plus
                    )
                    .frame(width: 40)
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        shouldUseRemainingDuration.toggle()
                    }
                }
            }
            .transition(.blurReplace)
            .matchedGeometryEffect(id: PlayerNamespace.timeText, in: namespace)
            
            Group {
                let value: Binding<CGFloat> = switch activeControl {
                case .progress: model.hasCurrentTrack ? $model.progress : .constant(0)
                case .volume: $model.volume
                }
                
                ProgressBar(value: value, isActive: $isProgressBarActive, externalOvershootSign: progressBarExternalOvershootSign) { oldValue, newValue in
                    if activeControl == .volume && oldValue <= 0 && newValue > 0 {
                        speakerButtonBounceAnimation.toggle()
                    }
                }
                .disabled(activeControl == .progress && !model.hasCurrentTrack)
            }
            .foregroundStyle(isProgressBarActive ? .primary : activeControl == .volume && model.isMuted ? .quaternary : .secondary)
            .backgroundStyle(.quinary)
            .padding(.horizontal, !isProgressBarHovering || isProgressBarActive ? 0 : 12)
            .onHover { hover in
                let canHover = activeControl == .volume
                guard canHover && hover else { return }
                
                isProgressBarHovering = true
            }
            .animation(.default.speed(2), value: model.isMuted)
            .matchedGeometryEffect(id: activeControl.id, in: namespace)
            
            Group {
                if activeControl == .progress {
                    DurationText(duration: model.duration)
                        .frame(width: 40)
                        .foregroundStyle(.secondary)
                }
            }
            .transition(.blurReplace)
            .matchedGeometryEffect(id: PlayerNamespace.durationText, in: namespace)
        }
        .frame(height: 12)
        .onHover { hover in
            guard !hover else { return }
            
            withAnimation {
                isProgressBarHovering = false
            }
        }
    }
    
    @ViewBuilder func playPauseIcon(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        Group {
            if model.hasCurrentTrack && model.isPlaying {
                Image(systemSymbol: .pauseFill)
                    .resizable()
            } else {
                Image(systemSymbol: .playFill)
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height)
    }
}

#Preview {
    @Previewable @State var model = PlayerModel()
    @Previewable @Namespace var namespace
    
    MiniPlayer(namespace: namespace, model: model)
}
