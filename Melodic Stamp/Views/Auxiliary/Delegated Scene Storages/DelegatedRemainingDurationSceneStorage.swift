//
//  DelegatedRemainingDurationSceneStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import Defaults
import SwiftUI

struct DelegatedRemainingDurationSceneStorage: View {
    @Default(.memorizesPlaybackPositions) private var memorizesPlaybackPositions

    @Binding var shouldUseRemainingDuration: Bool

    @SceneStorage(AppSceneStorage.shouldUseRemainingDuration()) private var flag: Bool?

    @State private var state: DelegatedSceneStorageState<Bool?> = .init()

    var body: some View {
        Color.clear
            .onAppear {
                state.isReady = memorizesPlaybackPositions
            }
            .onChange(of: flag) { _, newValue in
                state.value = newValue
            }
            .onChange(of: shouldUseRemainingDuration) { _, newValue in
                flag = newValue
            }
            .onChange(of: state.preparedValue) { _, newValue in
                guard let newValue else { return }

                if let flag = newValue {
                    shouldUseRemainingDuration = flag
                }

                state.isReady = false
            }
    }
}
