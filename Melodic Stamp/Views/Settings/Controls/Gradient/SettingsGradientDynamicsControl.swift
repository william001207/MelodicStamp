//
//  SettingsGradientDynamicsControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Defaults
import SwiftUI

struct SettingsGradientDynamicsControl: View {
    @Default(.gradientDynamics) private var dynamics
    @Default(.gradientAnimateWithAudio) private var animateWithAudio

    var body: some View {
        Picker("Gradient dynamics", selection: $dynamics) {
            Text("Plain")
                .tag(Defaults.GradientDynamics.plain)

            Divider()

            Text("Binary")
                .tag(Defaults.GradientDynamics.binary)

            Text("Ternary")
                .tag(Defaults.GradientDynamics.ternary)

            Text("Quaternion")
                .tag(Defaults.GradientDynamics.quaternion)
        }

        Toggle("Animate gradient with audio", isOn: $animateWithAudio)
            .disabled(!dynamics.canAnimateWithAudio)
    }
}
