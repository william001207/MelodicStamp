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
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
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
            
            HStack(alignment: .center, spacing: 8) {
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
            guard playerViewModel.nowPlaying != nil else { return .ignored }
            
            switch key.phase {
            case .down:
                guard !isPressingSpace else { return .ignored }
                
                playPause()
                isPressingSpace = true
                return .handled
            case .up:
                isPressingSpace = false
                return .handled
            default:
                return .ignored
            }
        }
        .onKeyPress(keys: [.leftArrow, .rightArrow]) { key in
            guard playerViewModel.nowPlaying != nil else { return .ignored }
            
            let sign: FloatingPointSign = key.key == .leftArrow ? .minus : .plus
            let modifiers = key.modifiers
            
            if modifiers.contains(.command) {
                switch sign {
                case .plus:
                    playerViewModel.nextTrack()
                    nextSongButtonBounceAnimation.toggle()
                case .minus:
                    playerViewModel.previousTrack()
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
                playerViewModel.adjustTime(multiplier: multiplier, sign: sign)
            case .volume:
                playerViewModel.adjustVolume(multiplier: Float(multiplier), sign: sign)
            }
            
            if !inRange {
                progressBarExternalOvershootSign = sign
            }
            
            return .handled
        }
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .up) { key in
            progressBarExternalOvershootSign = nil
            return .ignored
        }
        .onKeyPress(.escape) {
            guard activeControl == .volume else { return .ignored }
            
            activeControl = .progress
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
            
            ShrinkableMarqueeScrollView {
                MusicTitle()
            }
            .contentTransition(.numericText())
            .animation(.default, value: playerViewModel.playlist)
            
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
                playerViewModel.previousTrack()
                previousSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .backwardFill)
                    .imageScale(.large)
            }
            .disabled(!playerViewModel.canNavigatePrevious())
            .symbolEffect(.bounce, value: previousSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.previousSongButton, in: namespace)
            
            AliveButton {
                playPause()
                isPressingSpace = false
            } label: {
                playPauseImage(height: 16)
                    .frame(width: 16)
                    .contentTransition(.symbolEffect(.replace.upUp))
            }
            .scaleEffect(isPressingSpace ? 0.75 : 1, anchor: .center)
            .animation(.bouncy, value: isPressingSpace)
            .matchedGeometryEffect(id: PlayerNamespace.playPauseButton, in: namespace)
            
            AliveButton {
                playerViewModel.nextTrack()
                nextSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .forwardFill)
                    .imageScale(.large)
            }
            .disabled(!playerViewModel.canNavigateNext())
            .symbolEffect(.bounce, value: nextSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.nextSongButton, in: namespace)
        }
        //.disabled(!model.hasCurrent)
    }
    
    @ViewBuilder private func trailingControls() -> some View {
        AliveButton {
            switch activeControl {
            case .progress:
                activeControl = .volume
            case .volume:
                playerViewModel.isMuted.toggle()
            }
        } label: {
            playerViewModel.speakerImage
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
                    Text(formatTime(playerViewModel.elapsed))
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
                if playerViewModel.nowPlaying != nil {
                    let value: Binding<CGFloat> = switch activeControl {
                    case .progress: Binding(
                        get: { CGFloat(playerViewModel.progress) },
                        set: { newValue in
                            playerViewModel.seek(position: newValue)
                        }
                    )
                    case .volume: Binding(
                        get: { CGFloat(playerViewModel.volume) },
                        set: { newValue in
                            playerViewModel.volume = Float(newValue)
                        }
                    )
                    }
                    
                    ProgressBar(value: value, isActive: $isProgressBarActive, externalOvershootSign: progressBarExternalOvershootSign) { oldValue, newValue in
                        if activeControl == .volume && oldValue <= 0 && newValue > 0 {
                            speakerButtonBounceAnimation.toggle()
                        }
                    }
                } else {
                    ProgressBar(value: .constant(0), isActive: .constant(false))
                        .disabled(true)
                }
            }
            .foregroundStyle(isProgressBarActive ? .primary : activeControl == .volume && playerViewModel.isMuted ? .quaternary : .secondary)
            .backgroundStyle(.quinary)
            .padding(.horizontal, !isProgressBarHovering || isProgressBarActive ? 0 : 12)
            .onHover { hover in
                let canHover = activeControl == .volume
                guard canHover && hover else { return }
                
                isProgressBarHovering = true
            }
            .animation(.default.speed(2), value: playerViewModel.isMuted)
            .matchedGeometryEffect(id: activeControl.id, in: namespace)
            
            Group {
                if activeControl == .progress {
                    Text(formatTime(playerViewModel.remaining))
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
    
    @ViewBuilder func playPauseImage(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        Group {
            Image(systemSymbol: playerViewModel.player.isPlaying ? .pauseFill : .playFill)
                .resizable()
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height)
        .contentTransition(.symbolEffect(.replace))
    }
    
    func playPause() {
        do {
            try playerViewModel.togglePlayPause()
        } catch {
            playerViewModel.handleError(error)
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(abs(time))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
