//
//  DisplayLyricsInteractionStateButton.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/1.
//

import SFSafeSymbols
import SwiftUI
import SwiftState

struct DisplayLyricsInteractionStateButton: View, Animatable {
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    @Namespace private var namespace

    let interactionStateMachine: AppleMusicScrollViewInteractionState.Machine
    
    var progress: CGFloat
    var lineWidth: CGFloat = 4
    var hasProgressRing: Bool = true

    var body: some View {
        AliveButton(isOn: binding) {
            ZStack {
                Circle()
                    .foregroundStyle(.background)
                    .opacity(0.1)
                    .frame(width: 48)
                    .overlay {
                        if hasProgressRing {
                            ProgressView(value: max(0, min(1, progress)))
                                .progressViewStyle(.alive(lineWidth: lineWidth))
                                .padding(lineWidth / 2)
                        }
                    }

                Group {
                    if interactionStateMachine.state.isIsolated {
                        Image(systemSymbol: .lockOpenFill)
                    } else {
                        Image(systemSymbol: .lockFill)
                    }
                }
                .font(.title2)
            }
            .padding(12)
        }
        .animation(.default, value: hasProgressRing)
        .animation(.default, value: interactionStateMachine.state)
    }

    private var binding: Binding<Bool> {
        Binding {
            interactionStateMachine.state.isIsolated
        } set: { newValue in
            if newValue {
                interactionStateMachine <-! .isolate
            } else {
                interactionStateMachine <-! .follow
            }
        }
    }
}

#Preview {
    @Previewable @SwiftUI.State var progress: CGFloat = .zero
    
    lazy var interactionStateMachine: AppleMusicScrollViewInteractionState.Machine = .init(state: .following) { machine in
        machine.addRoutes(event: .isolate, transitions: [
            .any => .isolated
        ])
        machine.addRoutes(event: .follow, transitions: [
            .any => .following
        ])
    }

    VStack {
        DisplayLyricsInteractionStateButton(interactionStateMachine: interactionStateMachine, progress: progress)

        Slider(value: $progress, in: 0...1)
    }
    .padding()
}
