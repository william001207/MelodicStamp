//
//  AppleMusicLyricsViewInteractionStateButton.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/1.
//

import SFSafeSymbols
import SwiftUI

struct AppleMusicLyricsViewInteractionStateButton: View, Animatable {
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    @Binding var interactionState: AppleMusicLyricsViewInteractionState
    var progress: CGFloat
    var lineWidth: CGFloat = 4
    var hasProgressRing: Bool = true

    var body: some View {
        Button {} label: {
            ZStack {
                Color.clear
                    .hoverableBackground(isExplicitlyVisible: true)
                    .frame(width: 48, height: 48)
                    .overlay {
                        if hasProgressRing {
                            ProgressView(value: max(0, min(1, progress)))
                                .progressViewStyle(.alive(lineWidth: lineWidth))
                                .padding(lineWidth / 2)
                        }
                    }
                    .clipShape(.circle)

                Group {
                    if interactionState.isIsolated {
                        Image(systemSymbol: .lockOpenFill)
                    } else {
                        Image(systemSymbol: .lockFill)
                    }
                }
                .font(.title2)
            }
        }
        .buttonStyle(.alive(isOn: binding))
        .animation(.default, value: hasProgressRing)
        .animation(.default, value: interactionState)
    }

    private var binding: Binding<Bool> {
        Binding {
            interactionState.isIsolated
        } set: { newValue in
            if newValue {
                interactionState = .isolated
            } else {
                interactionState = .following
            }
        }
    }
}

#Preview {
    @Previewable @State var interactionState: AppleMusicLyricsViewInteractionState = .following
    @Previewable @State var progress: CGFloat = .zero

    VStack {
        AppleMusicLyricsViewInteractionStateButton(interactionState: $interactionState, progress: progress)

        Slider(value: $progress, in: 0...1)
    }
    .padding()
}
