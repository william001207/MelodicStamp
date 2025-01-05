//
//  AppleMusicLyricsViewInteractionModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

@Observable final class AppleMusicLyricsViewInteractionModel {
    var state: AppleMusicLyricsViewInteractionState = .following {
        didSet {
            update(state)
        }
    }

    var hasProgressRing: Bool = true
    var delegationProgress: CGFloat = .zero

    private var dispatch: DispatchWorkItem?

    func reset() {
        guard !state.isIsolated else { return }
        dispatch?.cancel()
        state = .intermediate

        let dspatch = DispatchWorkItem {
            self.state = .countingDown
        }
        dispatch = dspatch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: dspatch)
    }

    func update(_ state: AppleMusicLyricsViewInteractionState) {
        switch state {
        case .following:
            dispatch?.cancel()
            hasProgressRing = false
        case .countingDown:
            dispatch?.cancel()
            hasProgressRing = true

            delegationProgress = .zero
            withAnimation(.smooth(duration: 3)) {
                delegationProgress = 1
            }

            let dispatch = DispatchWorkItem {
                self.state = .following
            }
            self.dispatch = dispatch
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: dispatch)
        case .isolated:
            dispatch?.cancel()
            hasProgressRing = false

            withAnimation(.smooth) {
                delegationProgress = 1
            }
        default:
            break
        }
    }
}
