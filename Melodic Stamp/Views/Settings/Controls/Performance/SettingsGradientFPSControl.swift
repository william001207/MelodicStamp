//
//  SettingsGradientFPSControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Defaults
import SwiftUI

struct SettingsGradientFPSControl: View {
    @Default(.gradientFPS) private var fps

    var body: some View {
        Slider(
            value: binding,
            in: Defaults.GradientFPS.range.map(Int.init).map(Double.init),
            step: 10
        ) {
            Text("Gradient FPS")

            TextField(
                value: $fps.value,
                format: .number
            ) {
                EmptyView()
            }
            .labelsHidden()
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)
        } minimumValueLabel: {
            Text(verbatim: .init(format: "%d", Defaults.GradientFPS.range.lowerBound.value))
        } maximumValueLabel: {
            Text(verbatim: .init(format: "%d", Defaults.GradientFPS.range.upperBound.value))
        }
    }

    private var binding: Binding<Double> {
        Binding {
            Double(Int(fps))
        } set: { newValue in
            fps = .init(value: Int(newValue))
        }
    }
}
