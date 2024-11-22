//
//  Player.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI
import SFSafeSymbols

struct Player: View {
    
    @Environment(\.openWindow) var openWindow
    
    var namespace: Namespace.ID
    
    @State var model: PlayerModel = .shared
    
    @State private var isProgressBarActive: Bool = false
    @State private var isVolumeBarActive: Bool = false
    @State private var isPressingSpace: Bool = false
    
    @State private var shouldUseRemainingDuration: Bool = false
    @State private var progressBarExternalOvershootSign: FloatingPointSign?
    
    @State private var previousSongButtonBounceAnimation: Bool = false
    @State private var nextSongButtonBounceAnimation: Bool = false
    @State private var speakerButtonBounceAnimation: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header()
            
            HStack(alignment: .center, spacing: 24) {
                HStack(alignment: .center, spacing: 12) {
                    leadingControls()
                }
                
                Divider()
                
                TimelineView(.animation) { context in
                    HStack(alignment: .center, spacing: 12) {
                        progressBar()
                    }
                }
                
                Divider()
                
                HStack(alignment: .center, spacing: 24) {
                    trailingControls()
                }
            }
            .frame(height: 32)
            .animation(.default, value: isProgressBarActive)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .foregroundStyle(.thickMaterial)
        }
        
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
        .onKeyPress(keys: [.leftArrow, .rightArrow]) { key in
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
            
            let inRange = model.adjustTime(multiplier: multiplier, sign: sign)
            if !inRange {
                progressBarExternalOvershootSign = sign
            }
            
            return .handled
        }
        .onKeyPress(keys: [.leftArrow, .rightArrow], phases: .up) { key in
            progressBarExternalOvershootSign = nil
            return .ignored
        }
    }
    
    @ViewBuilder private func header() -> some View {
        HStack(alignment: .center, spacing: 12) {
            
            Spacer()
            
            ShrinkableMarqueeScrollView {
                MusicTitle(model: model)
            }
            .contentTransition(.numericText())
            .animation(.default, value: model.currentIndex)
            
            Spacer()
            
            AliveButton(enabledStyle: .init(.secondary)) {
                openWindow(id: "mini-player")
            } label: {
                Image(systemSymbol: .arrowDownRightAndArrowUpLeft)
                    .imageScale(.large)
                    .frame(width: 20)
            }
            .matchedGeometryEffect(id: PlayerNamespace.expandShrinkButton, in: namespace)
        }
        .padding(.leading, 20)
    }
    
    @ViewBuilder private func leadingControls() -> some View {
        Group {
            AliveButton(enabledStyle: .init(.secondary)) {
                model.previousTrack()
                previousSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .backwardFill)
                    .imageScale(.large)
            }
            .disabled(!model.hasPreviousTrack)
            .symbolEffect(.bounce, value: previousSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.previousSongButton, in: namespace)
            
            AliveButton {
                model.togglePlayPause()
                isPressingSpace = false
            } label: {
                model.playPauseImage
                    .frame(width: 24)
                    .contentTransition(.symbolEffect(.replace.upUp))
            }
            .scaleEffect(isPressingSpace ? 0.75 : 1, anchor: .center)
            .animation(.bouncy, value: isPressingSpace)
            .matchedGeometryEffect(id: PlayerNamespace.playPauseButton, in: namespace)
            
            AliveButton(enabledStyle: .init(.secondary)) {
                model.nextTrack()
                nextSongButtonBounceAnimation.toggle()
            } label: {
                Image(systemSymbol: .forwardFill)
                    .imageScale(.large)
            }
            .disabled(!model.hasNextTrack)
            .symbolEffect(.bounce, value: nextSongButtonBounceAnimation)
            .matchedGeometryEffect(id: PlayerNamespace.nextSongButton, in: namespace)
        }
        .disabled(!model.hasCurrentTrack)
    }
    
    @ViewBuilder private func trailingControls() -> some View {
        ProgressBar(value: $model.volume, isActive: $isVolumeBarActive) { oldValue, newValue in
            if oldValue <= 0 && newValue > 0 {
                speakerButtonBounceAnimation.toggle()
            }
        }
        .foregroundStyle(isVolumeBarActive ? .primary : model.isMuted ? .quaternary : .secondary)
        .backgroundStyle(.quinary)
        .frame(width: 72, height: 12)
        .animation(.default.speed(2), value: model.isMuted)
        .matchedGeometryEffect(id: PlayerNamespace.volumeBar, in: namespace)
        
        AliveButton {
            model.isMuted.toggle()
        } label: {
            model.speakerImage
                .imageScale(.large)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 16)
        }
        .symbolEffect(.bounce, value: speakerButtonBounceAnimation)
        .matchedGeometryEffect(id: PlayerNamespace.volumeButton, in: namespace)
    }
    
    @ViewBuilder private func progressBar() -> some View {
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
        .matchedGeometryEffect(id: PlayerNamespace.timeText, in: namespace)
        
        ProgressBar(value: $model.progress, isActive: $isProgressBarActive, externalOvershootSign: progressBarExternalOvershootSign)
            .foregroundStyle(isProgressBarActive ? .primary : .secondary)
            .backgroundStyle(.quinary)
            .frame(height: 12)
            .matchedGeometryEffect(id: PlayerNamespace.progressBar, in: namespace)
            .padding(.horizontal, isProgressBarActive ? 0 : 12)
        
        DurationText(duration: model.duration)
        .frame(width: 40)
        .foregroundStyle(.secondary)
        .matchedGeometryEffect(id: PlayerNamespace.durationText, in: namespace)
    }
}
