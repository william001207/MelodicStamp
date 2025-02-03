//
//  SettingsGradientResolutionControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Defaults
import SwiftUI

struct SettingsGradientResolutionControl: View {
    @Default(.gradientResolution) private var resolution

    var body: some View {
        Slider(
            value: $resolution.value,
            in: Defaults.GradientResolution.range.map(Double.init)
        ) {
            Text("Gradient Resolution")
            TextField(
                value: $resolution.value,
                format: .number.precision(.integerAndFractionLength(integerLimits: 1..., fractionLimits: 1...2))
            ) {
                EmptyView()
            }
            .labelsHidden()
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)
        } minimumValueLabel: {
            Text(verbatim: .init(format: "%.2f", Defaults.GradientResolution.range.lowerBound.value))
        } maximumValueLabel: {
            Text(verbatim: .init(format: "%.2f", Defaults.GradientResolution.range.upperBound.value))
        }
    }
}
